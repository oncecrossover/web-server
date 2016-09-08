package com.gibbon.peeq.util;

import java.util.HashMap;
import java.util.Map;

import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.Card;
import com.stripe.model.Charge;
import com.stripe.model.Customer;
import com.stripe.model.DeletedCard;
import com.stripe.model.DeletedCustomer;
import com.stripe.model.DeletedExternalAccount;
import com.stripe.model.Refund;

public class StripeUtil {
  static {
    Stripe.apiKey = "sk_test_qHGH10BjT9f7jSze3mhHijuU";
  }

  public static Customer getCustomer(final String cusId)
      throws StripeException {
    return Customer.retrieve(cusId);
  }

  public static Customer createCustomerForUser(final String uid)
      throws StripeException {
    final Map<String, Object> params = new HashMap<String, Object>();
    params.put("description", String.format("Customer for %s", uid));
    final Customer customer = Customer.create(params);
    return customer;
  }

  public static Customer createCustomerByCard(final String token)
      throws StripeException {
    final Map<String, Object> customerParams = new HashMap<String, Object>();
    customerParams.put("source", token);

    return Customer.create(customerParams);
  }

  public static Card addCardToCustomer(final Customer customer,
      final String token) throws StripeException {
    return customer.createCard(token);
  }

  public static DeletedCustomer deleteCustomer(final Customer customer)
      throws StripeException {
    return customer.delete();
  }

  public static Customer updateDefaultSource(final Customer customer,
      final Card card) throws StripeException {
    final Map<String, Object> updateParams = new HashMap<String, Object>();
    updateParams.put("default_source", card.getId());
    return customer.update(updateParams);
  }

  public static DeletedCard deleteCard(final Card card) throws StripeException {
    return card.delete();
  }

  public static DeletedExternalAccount deleteCard(final Customer customer,
      final String cardId) throws StripeException {
    return customer.getSources().retrieve(cardId).delete();
  }

  public static Charge chargeCustomerUncaptured(final String cusId,
      final double amount) throws StripeException {
    return chargeCustomer(cusId, amount, false);
  }

  public static Charge chargeCustomer(final String cusId, final double amount)
      throws StripeException {
    return chargeCustomer(cusId, amount, true);
  }

  static Charge chargeCustomer(final String cusId, final double amount,
      final boolean capture)
      throws StripeException {
    final long cents = StripeUtil.toCents(StripeUtil.ceilingValue(amount));

    final Map<String, Object> chargeParams = new HashMap<String, Object>();
    /* amount in cents */
    chargeParams.put("amount", cents);
    chargeParams.put("currency", "usd");
    chargeParams.put("customer", cusId);
    chargeParams.put("capture", capture);
    return Charge.create(chargeParams);
  }

  static double ceilingValue(final double amount) {
    return Math.ceil(amount * 100.0) / 100.0;
  }

  static long toCents(final double amount) {
    return (long)(ceilingValue(amount)*100);
  }

  public static Refund refundCharge(final String chargeId)
      throws StripeException {
    final Map<String, Object> refundParams = new HashMap<String, Object>();
    refundParams.put("charge", chargeId);

    Charge charge = Charge.retrieve(chargeId);
    if (!charge.getRefunded()) {
      return Refund.create(refundParams);
    } else {
      return null;
    }
  }

  public static Charge captureCharge(final String chargeId)
      throws StripeException {
    return Charge.retrieve(chargeId).capture();
  }
}
