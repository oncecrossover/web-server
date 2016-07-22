package com.gibbon.peeq.handlers;

import static org.junit.Assert.assertFalse;

import java.util.HashMap;
import java.util.Map;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.Token;

public class TestPaymentsWebHandler {
  private static final Logger LOG = LoggerFactory
      .getLogger(TestPaymentsWebHandler.class);

  @Test
  public void testTokenCreate() throws StripeException {
    Stripe.apiKey = "sk_test_qHGH10BjT9f7jSze3mhHijuU";

    Map<String, Object> tokenParams = new HashMap<String, Object>();
    Map<String, Object> cardParams = new HashMap<String, Object>();
    cardParams.put("number", "4242424242424242");
    cardParams.put("exp_month", 7);
    cardParams.put("exp_year", 2017);
    cardParams.put("cvc", "314");
    tokenParams.put("card", cardParams);

    final Token token = Token.create(tokenParams);
    assertFalse(token.getUsed());
    // id: tok_18ZwPKEl5MEVXMYq3za0qWZW
    LOG.info(token.toString());
  }
}
