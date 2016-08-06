package com.gibbon.peeq.util;

import static org.junit.Assert.assertEquals;

import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.junit.BeforeClass;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.Customer;
import com.stripe.model.DeletedCustomer;
import com.stripe.model.ExternalAccount;
import com.stripe.model.Token;

public class TestStripeUtils {

  private static final Logger LOG = LoggerFactory
      .getLogger(TestStripeUtils.class);

  static Map<String, Object> defaultTokenParams = new HashMap<String, Object>();
  static Map<String, Object> defaultCardParams = new HashMap<String, Object>();
  static Map<String, Object> defaultDebitTokenParams = new HashMap<String, Object>();
  static Map<String, Object> defaultDebitCardParams = new HashMap<String, Object>();

  @BeforeClass
  public static void beforeClass() {
    Stripe.apiKey = "sk_test_qHGH10BjT9f7jSze3mhHijuU";

    /* init card */
    defaultCardParams.put("number", "4242424242424242");
    defaultCardParams.put("exp_month", 12);
    defaultCardParams.put("exp_year", getYear());
    defaultCardParams.put("cvc", "123");
    defaultCardParams.put("name", "J Bindings Cardholder");
    defaultCardParams.put("address_line1", "140 2nd Street");
    defaultCardParams.put("address_line2", "4th Floor");
    defaultCardParams.put("address_city", "San Francisco");
    defaultCardParams.put("address_zip", "94105");
    defaultCardParams.put("address_state", "CA");
    defaultCardParams.put("address_country", "USA");

    /* init token params */
    defaultTokenParams.put("card", defaultCardParams);

    defaultDebitCardParams.put("number", "4000056655665556");
    defaultDebitCardParams.put("exp_month", 12);
    defaultDebitCardParams.put("exp_year", getYear());
    defaultDebitCardParams.put("cvc", "123");
    defaultDebitCardParams.put("name", "J Bindings Debitholder");
    defaultDebitCardParams.put("address_line1", "140 2nd Street");
    defaultDebitCardParams.put("address_line2", "4th Floor");
    defaultDebitCardParams.put("address_city", "San Francisco");
    defaultDebitCardParams.put("address_zip", "94105");
    defaultDebitCardParams.put("address_state", "CA");
    defaultDebitCardParams.put("address_country", "USA");

    /* init token params */
    defaultDebitTokenParams.put("card", defaultDebitCardParams);
  }

  static String getYear() {
    Date date = new Date(); // Get current date
    Calendar calendar = new GregorianCalendar();
    calendar.setTime(date);
    return calendar.get(Calendar.YEAR) + 1 + "";
  }

  @Test(timeout = 60000)
  public void testGetCustomer() throws StripeException {
    /* create new customer */
    final Customer customer = StripeUtils
        .createCustomerForUser("test@example.com");
    /* retrieve customer */
    final Customer retCustomer = StripeUtils.getCustomer(customer.getId());

    assertEquals(0, retCustomer.getAccountBalance().intValue());
    assertEquals(null, retCustomer.getDefaultSource());
    assertEquals(retCustomer.getDescription(), "Customer for test@example.com");
    assertEquals(0, retCustomer.getSources().getData().size());
  }

  @Test(timeout = 60000)
  public void testCreateCustomerForUser() throws StripeException {
    /* create new customer */
    final Customer customer = StripeUtils
        .createCustomerForUser("test@example.com");

    assertEquals(0, customer.getAccountBalance().intValue());
    assertEquals(null, customer.getDefaultSource());
    assertEquals(customer.getDescription(), "Customer for test@example.com");
    assertEquals(0, customer.getSources().getData().size());
  }

  @Test(timeout = 60000)
  public void testCreateCustomerByCard() throws StripeException {
    /* create new customer by token */
    final Token token = Token.create(defaultTokenParams);
    final Customer customer = StripeUtils.createCustomerByCard(token.getId());

    assertEquals(1, customer.getSources().getData().size());
    assertEquals(token.getCard().getId(), customer.getDefaultSource());
    assertEquals(token.getCard().getId(),
        customer.getSources().getData().get(0).getId());
  }

  @Test(timeout = 60000)
  public void testAddCardToCustomer() throws StripeException {
    /* create new customer */
    Customer customer = StripeUtils.createCustomerForUser("test@example.com");

    /* create new card by token */
    final Token token = Token.create(defaultTokenParams);
    StripeUtils.addCardToCustomer(customer, token.getId());

    /* retrieve updated customer */
    customer = Customer.retrieve(customer.getId());
    assertEquals(1, customer.getSources().getData().size());
    assertEquals(token.getCard().getId(), customer.getDefaultSource());
    assertEquals(token.getCard().getId(),
        customer.getSources().getData().get(0).getId());
  }

  @Test(timeout = 60000)
  public void testDeleteCustomer() throws StripeException {
    /* create new customer */
    final Customer customer = StripeUtils
        .createCustomerForUser("test@example.com");

    /* delete customer */
    DeletedCustomer deletedCustomer = StripeUtils.deleteCustomer(customer);
    assertEquals(customer.getId(), deletedCustomer.getId());
    assertEquals(true, deletedCustomer.getDeleted());
  }

  @Test(timeout = 60000)
  public void testUpdateDefaultSource() throws StripeException {
    /* create new customer */
    final Customer customer = StripeUtils
        .createCustomerForUser("test@example.com");

    /* add one card */
    final Token oneToken = Token.create(defaultTokenParams);
    StripeUtils.addCardToCustomer(customer, oneToken.getId());
    final Customer oneCustomer = Customer.retrieve(customer.getId());

    assertEquals(1, oneCustomer.getSources().getData().size());
    assertEquals(oneToken.getCard().getId(), oneCustomer.getDefaultSource());
    assertEquals(oneToken.getCard().getId(),
        oneCustomer.getSources().getData().get(0).getId());

    /* add another card */
    final Token anotherToken = Token.create(defaultDebitTokenParams);
    StripeUtils.addCardToCustomer(customer, anotherToken.getId());
    final Customer anotherCustomer = Customer.retrieve(customer.getId());

    assertEquals(2, anotherCustomer.getSources().getData().size());
    assertEquals(oneToken.getCard().getId(),
        anotherCustomer.getDefaultSource());
    assertEquals(oneToken.getCard().getId(),
        anotherCustomer.getSources().getData().get(0).getId());

    /* update default source */
    StripeUtils.updateDefaultSource(customer, anotherToken.getCard());
    final Customer defaultUpdatedCustomer = Customer.retrieve(customer.getId());
    assertEquals(2, defaultUpdatedCustomer.getSources().getData().size());
    assertEquals(anotherToken.getCard().getId(),
        defaultUpdatedCustomer.getDefaultSource());
    assertEquals(anotherToken.getCard().getId(),
        defaultUpdatedCustomer.getSources().getData().get(0).getId());
  }
}
