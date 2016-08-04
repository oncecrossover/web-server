package com.gibbon.peeq.util;

import java.util.HashMap;
import java.util.Map;

import com.stripe.Stripe;
import com.stripe.exception.APIConnectionException;
import com.stripe.exception.APIException;
import com.stripe.exception.AuthenticationException;
import com.stripe.exception.CardException;
import com.stripe.exception.InvalidRequestException;
import com.stripe.model.Card;
import com.stripe.model.Customer;

public class StripeUtils {
  static {
    Stripe.apiKey = "sk_test_qHGH10BjT9f7jSze3mhHijuU";
  }

  public static Customer getCustomer(final String cusId)
      throws AuthenticationException, InvalidRequestException,
      APIConnectionException, CardException, APIException {
    return Customer.retrieve(cusId);
  }

  public static Customer createCustomerForUser(final String uid)
      throws AuthenticationException, InvalidRequestException,
      APIConnectionException, CardException, APIException {
    final Map<String, Object> params = new HashMap<String, Object>();
    params.put("description", String.format("Customer for %s", uid));
    final Customer customer = Customer.create(params);
    return customer;
  }

  public static Customer createCustomerByCard(final String token)
      throws AuthenticationException, InvalidRequestException,
      APIConnectionException, CardException, APIException {
    final Map<String, Object> customerParams = new HashMap<String, Object>();
    customerParams.put("source", token);

    return Customer.create(customerParams);
  }

  public static Card addCardToCustomer(final Customer customer,
      final String token)
      throws AuthenticationException, InvalidRequestException,
      APIConnectionException, CardException, APIException {
    final Map<String, Object> params = new HashMap<String, Object>();
    params.put("source", token);
    return customer.createCard(params);
  }

  public static void deleteCustomer(final Customer customer)
      throws AuthenticationException, InvalidRequestException,
      APIConnectionException, CardException, APIException {
    customer.delete();
  }
}
