package com.gibbon.peeq.util;

import static org.junit.Assert.assertEquals;

import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Map;

import org.junit.BeforeClass;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.Card;
import com.stripe.model.Charge;
import com.stripe.model.Customer;
import com.stripe.model.DeletedCard;
import com.stripe.model.DeletedCustomer;
import com.stripe.model.DeletedExternalAccount;
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

  @Test(timeout = 60000)
  public void testDeleteCard() throws StripeException {
    /* create new customer */
    Customer customer = StripeUtils.createCustomerForUser("test@example.com");

    /* create new card by token */
    final Token token = Token.create(defaultTokenParams);
    final Card card = StripeUtils.addCardToCustomer(customer, token.getId());

    /* retrieve updated customer */
    customer = Customer.retrieve(customer.getId());
    assertEquals(1, customer.getSources().getData().size());
    assertEquals(token.getCard().getId(), customer.getDefaultSource());
    assertEquals(token.getCard().getId(),
        customer.getSources().getData().get(0).getId());

    /* delete card */
    DeletedCard deletedCard = StripeUtils.deleteCard(card);
    assertEquals(true, deletedCard.getDeleted());
    assertEquals(card.getId(), deletedCard.getId());

    /* retrieve updated customer */
    customer = Customer.retrieve(customer.getId());
    assertEquals(0, customer.getSources().getData().size());
    assertEquals(null, customer.getDefaultSource());
  }

  @Test(timeout = 60000)
  public void testDeleteCardById() throws StripeException {
    /* create new customer */
    final Customer customer = StripeUtils
        .createCustomerForUser("test@example.com");

    /* add one card */
    final Token oneToken = Token.create(defaultTokenParams);
    final Card oneCard = StripeUtils.addCardToCustomer(customer,
        oneToken.getId());
    final Customer oneCustomer = Customer.retrieve(customer.getId());

    assertEquals(1, oneCustomer.getSources().getData().size());
    assertEquals(oneToken.getCard().getId(), oneCustomer.getDefaultSource());
    assertEquals(oneToken.getCard().getId(),
        oneCustomer.getSources().getData().get(0).getId());

    /* add another card */
    final Token anotherToken = Token.create(defaultDebitTokenParams);
    final Card anotherCard = StripeUtils.addCardToCustomer(customer,
        anotherToken.getId());
    final Customer anotherCustomer = Customer.retrieve(customer.getId());

    assertEquals(2, anotherCustomer.getSources().getData().size());
    assertEquals(oneToken.getCard().getId(),
        anotherCustomer.getDefaultSource());
    assertEquals(oneToken.getCard().getId(),
        anotherCustomer.getSources().getData().get(0).getId());

    /* delete one card */
    final DeletedExternalAccount oneDeletedAccount = StripeUtils
        .deleteCard(oneCustomer, oneCard.getId());
    assertEquals(true, oneDeletedAccount.getDeleted());
    assertEquals(oneCard.getId(), oneDeletedAccount.getId());

    final Customer oneDeletedAccountCustomer = Customer
        .retrieve(customer.getId());

    assertEquals(1, oneDeletedAccountCustomer.getSources().getData().size());
    assertEquals(anotherToken.getCard().getId(),
        oneDeletedAccountCustomer.getDefaultSource());
    assertEquals(anotherToken.getCard().getId(),
        oneDeletedAccountCustomer.getSources().getData().get(0).getId());

    /* delete another card */
    final DeletedExternalAccount anotherDeletedAccount = StripeUtils
        .deleteCard(anotherCustomer, anotherCard.getId());
    assertEquals(true, anotherDeletedAccount.getDeleted());
    assertEquals(anotherCard.getId(), anotherDeletedAccount.getId());

    final Customer anotherDeletedAccountCustomer = Customer
        .retrieve(customer.getId());

    assertEquals(0,
        anotherDeletedAccountCustomer.getSources().getData().size());
    assertEquals(null, anotherDeletedAccountCustomer.getDefaultSource());
  }

  @Test(timeout = 60000)
  public void testChargeCustomer() throws StripeException {
    /* create new customer */
    Customer customer = StripeUtils.createCustomerForUser("test@example.com");

    /* create new card by token */
    final Token token = Token.create(defaultTokenParams);
    final Card card = StripeUtils.addCardToCustomer(customer, token.getId());

    Charge charge = null;
    charge = StripeUtils.chargeCustomer(customer.getId(), 1.5);
    assertEquals(150, charge.getAmount().intValue());

    charge = StripeUtils.chargeCustomer(customer.getId(), 1.52);
    assertEquals(152, charge.getAmount().intValue());

    charge = StripeUtils.chargeCustomer(customer.getId(), 1.55);
    assertEquals(155, charge.getAmount().intValue());

    charge = StripeUtils.chargeCustomer(customer.getId(), 1.57);
    assertEquals(157, charge.getAmount().intValue());

    charge = StripeUtils.chargeCustomer(customer.getId(), 1.501);
    assertEquals(151, charge.getAmount().intValue());

    charge = StripeUtils.chargeCustomer(customer.getId(), 1.504);
    assertEquals(151, charge.getAmount().intValue());

    charge = StripeUtils.chargeCustomer(customer.getId(), 1.505);
    assertEquals(151, charge.getAmount().intValue());

    charge = StripeUtils.chargeCustomer(customer.getId(), 1.507);
    assertEquals(151, charge.getAmount().intValue());
  }

  @Test(timeout = 60000)
  public void testCeilToDecimalPoints() throws StripeException {
    double amount = 0;
    double round = 0;
    long charge = 0;

    amount = 1.5;
    round = StripeUtils.ceilingValue(amount);
    assertEquals(1.5, round, 0);
    charge = StripeUtils.toCents(round);
    assertEquals(150, charge);

    amount = 1.52;
    round = StripeUtils.ceilingValue(amount);
    assertEquals(1.52, round, 0);
    charge = StripeUtils.toCents(round);
    assertEquals(152, charge);

    amount = 1.55;
    round = StripeUtils.ceilingValue(amount);
    assertEquals(1.55, round, 0);
    charge = StripeUtils.toCents(round);
    assertEquals(155, charge);

    amount = 1.57;
    round = StripeUtils.ceilingValue(amount);
    assertEquals(1.57, round, 0);
    charge = StripeUtils.toCents(round);
    assertEquals(157, charge);

    amount = 1.501;
    round = StripeUtils.ceilingValue(amount);
    assertEquals(1.51, round, 0);
    charge = StripeUtils.toCents(round);
    assertEquals(151, charge);

    amount = 1.504;
    round = StripeUtils.ceilingValue(amount);
    assertEquals(1.51, round, 0);
    charge = StripeUtils.toCents(round);
    assertEquals(151, charge);

    amount = 1.505;
    round = StripeUtils.ceilingValue(amount);
    assertEquals(1.51, round, 0);
    charge = StripeUtils.toCents(round);
    assertEquals(151, charge);

    amount = 1.507;
    round = StripeUtils.ceilingValue(amount);
    assertEquals(1.51, round, 0);
    charge = StripeUtils.toCents(round);
    assertEquals(151, charge);
  }

  //@Test(timeout = 60000)
  public void testGenerateCustomer() throws StripeException {
    /* create new customer */
    final Customer customer = StripeUtils
        .createCustomerForUser("test@example.com");
    System.out.println(customer.toString());

    /* create new token */
    Token token = Token.create(defaultTokenParams);
    System.out.println(token.toString());
    token = Token.create(defaultTokenParams);
    System.out.println(token.toString());
    token = Token.create(defaultTokenParams);
    System.out.println(token.toString());
    token = Token.create(defaultTokenParams);
    System.out.println(token.toString());
  }

  // @Test(timeout = 60000)
  public void testVerifyCustomer() throws StripeException {
    Customer customer = StripeUtils.getCustomer("cus_8xUE4dwv0HMu9Z");
    System.out.println(customer.toString());
    customer = StripeUtils.getCustomer("cus_8xUGEPr984Lmrc");
    System.out.println(customer.toString());
  }
}
