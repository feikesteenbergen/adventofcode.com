--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = adventofcode, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: input; Type: TABLE; Schema: adventofcode; Owner: feike
--

CREATE TABLE input (
    day integer NOT NULL,
    input text NOT NULL,
    CONSTRAINT input_day_check CHECK (((day >= 1) AND (day <= 25)))
);


ALTER TABLE input OWNER TO feike;

--
-- PostgreSQL database dump complete
--

