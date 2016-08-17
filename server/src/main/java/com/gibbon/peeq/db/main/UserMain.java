package com.gibbon.peeq.db.main;

import org.hibernate.Session;

import com.gibbon.peeq.db.model.User;
import com.gibbon.peeq.db.util.HibernateUtil;

public class UserMain {

  // Get Session
  private static Session session = HibernateUtil.getSessionFactory()
      .getCurrentSession();

  public static void main(String[] args) {
    // insertUser();
    qeuryUser();

    // terminate session factory, otherwise program won't end
    HibernateUtil.getSessionFactory().close();
  }

  private static void qeuryUser() {
    session.beginTransaction();
    User user = (User) session.get(User.class, "xiaobingo");
    session.getTransaction().commit();
    System.out.println(user);
  }

  private static void insertUser() {
    User user = new User();
    user.setUid("xiaobingo");
    user.setPwd("123");

    // start transaction
    session.beginTransaction();
    // Save the Model object
    session.save(user);
    // Commit transaction
    session.getTransaction().commit();
    System.out.println("User ID=" + user.getUid());
  }
}
