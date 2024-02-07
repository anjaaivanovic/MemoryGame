package com.example.projekat;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

public class Database {
    static EntityManagerFactory factory = Persistence.createEntityManagerFactory("default");
    public static EntityManagerFactory getEntityManagerFactory(){
        return factory;
    }
}
