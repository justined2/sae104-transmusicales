--
-- Base de données recensant les informations des différentes éditions des Transmusicales depuis leur création
-- Groupe D24 : Corentin, Justine Verger
--  

-- Initialisation du schéma

DROP SCHEMA IF EXISTS transmusicales CASCADE;
CREATE SCHEMA transmusicales;
SET SCHEMA 'transmusicales';

---
--- Table _annee
---

DROP TABLE IF EXISTS _annee;
CREATE TABLE _annee 
(
    an  NUMERIC(4)  NOT NULL, 

    CONSTRAINT annee_pk PRIMARY KEY (an)
);

---
--- Table _pays
---

DROP TABLE IF EXISTS _pays;
CREATE TABLE _pays
(
    nom_p   VARCHAR(30)     NOT NULL, 

    CONSTRAINT pays_pk PRIMARY KEY (nom_p)
);

---
--- Table _ville
---

DROP TABLE IF EXISTS _ville;
CREATE TABLE _ville
(
    nom_v       VARCHAR(30)     NOT NULL,
    nomp_ville  VARCHAR(30)     NOT NULL,

    CONSTRAINT ville_pk PRIMARY KEY (nom_v),
    CONSTRAINT ville_fk_pays FOREIGN KEY (nomp_ville) REFERENCES _pays (nom_p)
);

---
--- Table _lieu
---

DROP TABLE IF EXISTS _lieu;
CREATE TABLE _lieu
(
    id_lieu		    CHAR(10)        NOT NULL,
	nom_lieu		VARCHAR(50)	    NOT NULL,
	accesPMR		BOOLEAN		    NULL,
	capacite_max    NUMERIC(4,0)	NOT NULL,
    type_lieu       VARCHAR(20)     NOT NULL,
    nomv_lieu       VARCHAR(30)     NOT NULL,

    CONSTRAINT lieu_pk PRIMARY KEY (id_lieu),
    CONSTRAINT lieu_fk_ville FOREIGN KEY (nomv_lieu) REFERENCES _ville (nom_v)
);

---
--- Table _formation
---

DROP TABLE IF EXISTS _formation;
CREATE TABLE _formation
(
    libelle_formation	 VARCHAR(50)    NOT NULL,

    CONSTRAINT formation_pk PRIMARY KEY (libelle_formation)
);

---
--- Table _type_musique
---

DROP TABLE IF EXISTS _type_musique;
CREATE TABLE _type_musique
(
    type_m	 VARCHAR(30)    NOT NULL,

    CONSTRAINT type_musique_pk PRIMARY KEY (type_m)
);

---
--- Table _groupe_artiste
---

DROP TABLE IF EXISTS _groupe_artiste;
CREATE TABLE _groupe_artiste
(
    id_groupe_artiste   	CHAR(10)  	    NOT NULL,
    nom_groupe   		    VARCHAR(50)   	NOT NULL,       
    site_web   			    VARCHAR(50)  	NULL,
    annee_debut_ga          NUMERIC(4,0)    NULL,           -- Nous posons la contrainte à NULL car de nombreuses années du début du groupe/artiste ne sont pas renseignées dans le fichier .csv fourni  
    annee_sortie_disco_ga   NUMERIC(4,0)    NULL,           -- Nous posons la contrainte à NULL car de nombreuses années de sortie discographique ne sont pas renseignées dans le fichier .csv fourni 
    nomp_ga                 VARCHAR(30)     NOT NULL,

    CONSTRAINT groupe_artiste_pk PRIMARY KEY (id_groupe_artiste),
    CONSTRAINT groupe_artiste_uk UNIQUE(site_web),

    CONSTRAINT groupe_artiste_fk_annee_debut FOREIGN KEY (annee_debut_ga) REFERENCES _annee (an),
    CONSTRAINT groupe_artiste_fk_annee_sortie_disco FOREIGN KEY (annee_sortie_disco_ga) REFERENCES _annee (an),
    CONSTRAINT groupe_artiste_fk_pays FOREIGN KEY (nomp_ga) REFERENCES _pays (nom_p)
);

---
--- Table _type_principal
---

DROP TABLE IF EXISTS _type_principal;
CREATE TABLE _type_principal
(
    ga_typeprinc        CHAR(10)  	NOT NULL,
    typem_typeprinc     VARCHAR(30) NOT NULL,

    CONSTRAINT type_principal_pk PRIMARY KEY (ga_typeprinc, typem_typeprinc),
    CONSTRAINT type_principal_fk_groupe_artiste FOREIGN KEY (ga_typeprinc) REFERENCES _groupe_artiste (id_groupe_artiste),
    CONSTRAINT type_principal_fk_type_musique FOREIGN KEY (typem_typeprinc) REFERENCES _type_musique (type_m)
);

DROP TABLE IF EXISTS _type_ponctuel;
CREATE TABLE _type_ponctuel
(
    ga_typep    CHAR(10)  	NOT NULL,
    typem_typep VARCHAR(30) NOT NULL,

    CONSTRAINT type_ponctuel_pk PRIMARY KEY (ga_typep, typem_typep),
    CONSTRAINT type_ponctuel_fk_groupe_artiste FOREIGN KEY (ga_typep) REFERENCES _groupe_artiste (id_groupe_artiste),
    CONSTRAINT type_ponctuel_fk_type_musique FOREIGN KEY (typem_typep) REFERENCES _type_musique (type_m)
);

---
--- Table _composition_formation
---

DROP TABLE IF EXISTS _composition_formation;
CREATE TABLE _composition_formation
(
    ga_compofor         CHAR(10)  	NOT NULL,
    formation_compofor  VARCHAR(30) NOT NULL,

    CONSTRAINT composition_formation_pk PRIMARY KEY (ga_compofor, formation_compofor),
    CONSTRAINT composition_formation_fk_groupe_artiste FOREIGN KEY (ga_compofor) REFERENCES _groupe_artiste (id_groupe_artiste),
    CONSTRAINT composition_formation_fk_formation FOREIGN KEY (formation_compofor) REFERENCES _formation (libelle_formation)
);

---
--- Table _edition
---

DROP TABLE IF EXISTS _edition;
CREATE TABLE _edition
(
    nom_edition   VARCHAR(100)          NOT NULL,
    annee_edition NUMERIC(4,0)          NOT NULL, 

    CONSTRAINT edition_pk PRIMARY KEY (nom_edition),
    CONSTRAINT edition_fk_annee FOREIGN KEY (annee_edition) REFERENCES _annee (an)
);

---
--- Table _concert
---

DROP TABLE IF EXISTS _concert;
CREATE TABLE _concert
(
    no_concert		    CHAR(10)  	    NOT NULL,
    titre 	  	        VARCHAR(30)     NOT NULL,
    resume		        VARCHAR(255)    NOT NULL,
    duree		  	    NUMERIC(3,0)    NOT NULL,
    tarif			    NUMERIC(5,2)	NOT NULL,
    typem_concert       VARCHAR(30)     NOT NULL,
    edition_concert     VARCHAR(100)    NOT NULL,

    CONSTRAINT concert_pk PRIMARY KEY (no_concert),
    CONSTRAINT concert_chk CHECK(duree > 0 AND tarif > 0),
    CONSTRAINT concert_fk_type_musique FOREIGN KEY (typem_concert) REFERENCES _type_musique (type_m),
    CONSTRAINT concert_fk_edition FOREIGN KEY (edition_concert) REFERENCES _edition (nom_edition)
);

---
--- Table _representation
---

DROP TABLE IF EXISTS _representation;
CREATE TABLE _representation
(
    numero_representation  	    CHAR(10)    NOT NULL, 
    heure		  		        CHAR(5)   	NOT NULL, -- au format '23:59'
    date_representation	        CHAR(8)		NOT NULL,
    ga_representation           CHAR(10)  	NOT NULL,
    concert_representation      CHAR(10)  	NOT NULL,
    lieu_representation         CHAR(10)    NOT NULL,

   CONSTRAINT representation_pk PRIMARY KEY (numero_representation),
   CONSTRAINT representation_fk_groupe_artiste FOREIGN KEY (ga_representation) REFERENCES _groupe_artiste (id_groupe_artiste),
   CONSTRAINT representation_fk_concert FOREIGN KEY (concert_representation) REFERENCES _concert (no_concert),
   CONSTRAINT representation_fk_lieu FOREIGN KEY (lieu_representation) REFERENCES _lieu (id_lieu)
);