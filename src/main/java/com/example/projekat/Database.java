package com.example.projekat;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

public class Database {
    static EntityManagerFactory factory = Persistence.createEntityManagerFactory("default");
    static EntityManager entityManager = null;

    public static EntityManager getConnection(){
        if (entityManager == null) entityManager = factory.createEntityManager();
        return entityManager;
    }
}
