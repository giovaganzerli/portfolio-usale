--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.4
-- Dumped by pg_dump version 9.6.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

--
-- Name: fn_create_area(); Type: FUNCTION; Schema: public; Owner: cocacola
--

CREATE FUNCTION fn_create_area() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if not exists (select id from "area" where code = new.area_code) then
    insert into "area" (code) values (new.area_code);
  END if;

  return new;
end
$$;


ALTER FUNCTION public.fn_create_area() OWNER TO cocacola;

--
-- Name: fn_create_team(); Type: FUNCTION; Schema: public; Owner: cocacola
--

CREATE FUNCTION fn_create_team() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if not exists (
      select id from "team"
      where code = new.team_code
      and area_code = new.area_code
  ) then
    insert into "team" (code, area_code) values (new.team_code, new.area_code);
  END if;

  return new;
end
$$;


ALTER FUNCTION public.fn_create_team() OWNER TO cocacola;

--
-- Name: fn_multiply_points(); Type: FUNCTION; Schema: public; Owner: cocacola
--

CREATE FUNCTION fn_multiply_points() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if tg_op = 'UPDATE' or tg_op = 'DELETE' THEN
    update "team"
    set points = points / old.multiplier
    where old.team_code = "team".code;
  END IF;

  if tg_op = 'UPDATE' or tg_op = 'INSERT' THEN
    update "team"
    set points = points * new.multiplier
    where new.team_code = "team".code;
  END IF;

  return new;
end
$$;


ALTER FUNCTION public.fn_multiply_points() OWNER TO cocacola;

--
-- Name: fn_update_ended_at(); Type: FUNCTION; Schema: public; Owner: cocacola
--

CREATE FUNCTION fn_update_ended_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  NEW.ended_at := new.refreshed_at;
  return NEW;
end
$$;


ALTER FUNCTION public.fn_update_ended_at() OWNER TO cocacola;

--
-- Name: fn_update_points(); Type: FUNCTION; Schema: public; Owner: cocacola
--

CREATE FUNCTION fn_update_points() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if tg_op = 'UPDATE' or tg_op = 'DELETE' THEN
    update "user"
    set points = points - old.points
    where old.user_id = "user".id;

    update "team"
    set points = points - old.points
    where old.team_code = "team".code;

    update "area"
    set points = points - old.points
    where old.area_code = "area".code;
  END IF;

  if tg_op = 'UPDATE' or tg_op = 'INSERT' THEN
    update "user"
    set points = points + new.points
    where new.user_id = "user".id;

    update "team"
    set points = points + new.points
    where new.team_code = "team".code;

    update "area"
    set points = points + new.points
    where new.area_code = "area".code;
  END IF;

  return new;
end
$$;


ALTER FUNCTION public.fn_update_points() OWNER TO cocacola;

--
-- Name: fn_update_seconds(); Type: FUNCTION; Schema: public; Owner: cocacola
--

CREATE FUNCTION fn_update_seconds() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if tg_op = 'UPDATE' or tg_op = 'DELETE' THEN
    update "user"
    set seconds = seconds - date_part('epoch'::text, (old.refreshed_at - old.started_at))
    where old.user_id = "user".id;

    update "team"
    set seconds = seconds - date_part('epoch'::text, (old.refreshed_at - old.started_at))
    where old.team_code = "team".code;

    update "area"
    set seconds = seconds - date_part('epoch'::text, (old.refreshed_at - old.started_at))
    where old.area_code = "area".code;
  END IF;

  if tg_op = 'UPDATE' or tg_op = 'INSERT' THEN
    update "user"
    set seconds = seconds + date_part('epoch'::text, (new.refreshed_at - new.started_at))
    where new.user_id = "user".id;

    update "team"
    set seconds = seconds + date_part('epoch'::text, (new.refreshed_at - new.started_at))
    where new.team_code = "team".code;

    update "area"
    set seconds = seconds + date_part('epoch'::text, (new.refreshed_at - new.started_at))
    where new.area_code = "area".code;
  END IF;

  return new;
end
$$;


ALTER FUNCTION public.fn_update_seconds() OWNER TO cocacola;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: area; Type: TABLE; Schema: public; Owner: cocacola
--

CREATE TABLE area (
    id integer NOT NULL,
    code character varying NOT NULL,
    points integer DEFAULT 0 NOT NULL,
    seconds double precision DEFAULT 0 NOT NULL
);


ALTER TABLE area OWNER TO cocacola;

--
-- Name: area_id_seq; Type: SEQUENCE; Schema: public; Owner: cocacola
--

CREATE SEQUENCE area_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE area_id_seq OWNER TO cocacola;

--
-- Name: area_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cocacola
--

ALTER SEQUENCE area_id_seq OWNED BY area.id;


--
-- Name: game_action; Type: TABLE; Schema: public; Owner: cocacola
--

CREATE TABLE game_action (
    id integer NOT NULL,
    game_id integer NOT NULL,
    item_id integer,
    user_id integer NOT NULL,
    occurred_at timestamp without time zone NOT NULL,
    points integer NOT NULL,
    team_code character varying NOT NULL,
    area_code character varying NOT NULL
);


ALTER TABLE game_action OWNER TO cocacola;

--
-- Name: game_action_id_seq; Type: SEQUENCE; Schema: public; Owner: cocacola
--

CREATE SEQUENCE game_action_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE game_action_id_seq OWNER TO cocacola;

--
-- Name: game_action_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cocacola
--

ALTER SEQUENCE game_action_id_seq OWNED BY game_action.id;


--
-- Name: game_session; Type: TABLE; Schema: public; Owner: cocacola
--

CREATE TABLE game_session (
    id integer NOT NULL,
    user_id integer NOT NULL,
    game_id integer NOT NULL,
    started_at timestamp without time zone NOT NULL,
    refreshed_at timestamp without time zone NOT NULL,
    team_code character varying NOT NULL,
    area_code character varying NOT NULL
);


ALTER TABLE game_session OWNER TO cocacola;

--
-- Name: game_session_id_seq; Type: SEQUENCE; Schema: public; Owner: cocacola
--

CREATE SEQUENCE game_session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE game_session_id_seq OWNER TO cocacola;

--
-- Name: game_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cocacola
--

ALTER SEQUENCE game_session_id_seq OWNED BY game_session.id;


--
-- Name: point_multiplier; Type: TABLE; Schema: public; Owner: cocacola
--

CREATE TABLE point_multiplier (
    id integer NOT NULL,
    user_id integer NOT NULL,
    team_code character varying NOT NULL,
    area_code character varying NOT NULL,
    multiplier double precision DEFAULT 1 NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    special_game_id integer NOT NULL,
    CONSTRAINT check_positive CHECK ((multiplier > (0)::double precision))
);


ALTER TABLE point_multiplier OWNER TO cocacola;

--
-- Name: point_multiplier_id_seq; Type: SEQUENCE; Schema: public; Owner: cocacola
--

CREATE SEQUENCE point_multiplier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE point_multiplier_id_seq OWNER TO cocacola;

--
-- Name: point_multiplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cocacola
--

ALTER SEQUENCE point_multiplier_id_seq OWNED BY point_multiplier.id;


--
-- Name: team; Type: TABLE; Schema: public; Owner: cocacola
--

CREATE TABLE team (
    id integer NOT NULL,
    code character varying NOT NULL,
    points integer DEFAULT 0 NOT NULL,
    seconds double precision DEFAULT 0 NOT NULL,
    area_code character varying NOT NULL
);


ALTER TABLE team OWNER TO cocacola;

--
-- Name: team_id_seq; Type: SEQUENCE; Schema: public; Owner: cocacola
--

CREATE SEQUENCE team_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE team_id_seq OWNER TO cocacola;

--
-- Name: team_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cocacola
--

ALTER SEQUENCE team_id_seq OWNED BY team.id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: cocacola
--

CREATE TABLE "user" (
    id integer NOT NULL,
    name character varying NOT NULL,
    surname character varying NOT NULL,
    app_code character varying NOT NULL,
    team_code character varying NOT NULL,
    area_code character varying NOT NULL,
    role smallint DEFAULT 1 NOT NULL,
    curr_game_id integer DEFAULT 1 NOT NULL,
    seconds double precision DEFAULT 0 NOT NULL,
    points integer DEFAULT 0 NOT NULL,
    curr_special_game_id integer DEFAULT 1 NOT NULL
);


ALTER TABLE "user" OWNER TO cocacola;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: cocacola
--

CREATE SEQUENCE user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE user_id_seq OWNER TO cocacola;

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cocacola
--

ALTER SEQUENCE user_id_seq OWNED BY "user".id;


--
-- Name: vw_valid_area; Type: VIEW; Schema: public; Owner: cocacola
--

CREATE VIEW vw_valid_area AS
 SELECT area.id,
    area.code,
    area.points,
    area.seconds
   FROM area
  WHERE ((area.id IN ( SELECT DISTINCT a.id
           FROM (area a
             JOIN "user" u ON (((a.code)::text = (u.area_code)::text)))
          WHERE ((u.role < 4) AND ((u.app_code)::text !~~* '%lagroup%'::text)))) AND ((area.code)::text <> ''::text));


ALTER TABLE vw_valid_area OWNER TO cocacola;

--
-- Name: vw_area_scoreboard; Type: VIEW; Schema: public; Owner: cocacola
--

CREATE VIEW vw_area_scoreboard AS
 SELECT a.id,
    '' AS name,
    '' AS team_code,
    a.code AS area_code,
    a.points,
    (round(a.seconds))::integer AS seconds,
        CASE
            WHEN (a.seconds <> (0)::double precision) THEN round((((a.points)::double precision / a.seconds))::numeric, 2)
            ELSE (0)::numeric
        END AS coins
   FROM vw_valid_area a;


ALTER TABLE vw_area_scoreboard OWNER TO cocacola;

--
-- Name: vw_seconds; Type: VIEW; Schema: public; Owner: cocacola
--

CREATE VIEW vw_seconds AS
 SELECT game_session.user_id,
    game_session.team_code,
    game_session.area_code,
    game_session.game_id,
    date_part('epoch'::text, (game_session.refreshed_at - game_session.started_at)) AS seconds
   FROM game_session;


ALTER TABLE vw_seconds OWNER TO cocacola;

--
-- Name: vw_valid_team; Type: VIEW; Schema: public; Owner: cocacola
--

CREATE VIEW vw_valid_team AS
 SELECT team.id,
    team.code,
    team.points,
    team.seconds,
    team.area_code
   FROM team
  WHERE ((team.id IN ( SELECT DISTINCT t.id
           FROM (team t
             JOIN "user" u ON (((t.code)::text = (u.team_code)::text)))
          WHERE ((u.role < 3) AND ((u.app_code)::text !~~* '%lagroup%'::text)))) AND ((team.code)::text <> ''::text));


ALTER TABLE vw_valid_team OWNER TO cocacola;

--
-- Name: vw_team_leader; Type: VIEW; Schema: public; Owner: cocacola
--

CREATE VIEW vw_team_leader AS
 SELECT u.id,
    u.name,
    u.surname,
    u.app_code,
    u.team_code,
    u.area_code,
    u.role,
    u.curr_game_id,
    u.seconds,
    u.points,
    u.curr_special_game_id
   FROM (vw_valid_team t
     LEFT JOIN "user" u ON ((((t.code)::text = (u.team_code)::text) AND ((t.area_code)::text = (u.area_code)::text))))
  WHERE (u.role = 2);


ALTER TABLE vw_team_leader OWNER TO cocacola;

--
-- Name: vw_team_scoreboard; Type: VIEW; Schema: public; Owner: cocacola
--

CREATE VIEW vw_team_scoreboard AS
 SELECT t.id,
    '' AS name,
    t.code AS team_code,
    t.area_code,
    t.points,
    (round(t.seconds))::integer AS seconds,
        CASE
            WHEN (t.seconds <> (0)::double precision) THEN round((((t.points)::double precision / t.seconds))::numeric, 2)
            ELSE (0)::numeric
        END AS coins,
    COALESCE((tl.curr_special_game_id - 1), 0) AS games
   FROM (vw_valid_team t
     LEFT JOIN vw_team_leader tl ON ((((t.code)::text = (tl.team_code)::text) AND ((t.area_code)::text = (tl.area_code)::text))));


ALTER TABLE vw_team_scoreboard OWNER TO cocacola;

--
-- Name: vw_valid_user; Type: VIEW; Schema: public; Owner: cocacola
--

CREATE VIEW vw_valid_user AS
 SELECT "user".id,
    "user".name,
    "user".surname,
    "user".app_code,
    "user".team_code,
    "user".area_code,
    "user".role,
    "user".curr_game_id,
    "user".seconds,
    "user".points,
    "user".curr_special_game_id
   FROM "user"
  WHERE ((("user".name)::text <> ''::text) AND (("user".surname)::text <> ''::text) AND ("user".role < 4) AND (("user".app_code)::text !~~* '%lagroup%'::text));


ALTER TABLE vw_valid_user OWNER TO cocacola;

--
-- Name: vw_user_scoreboard; Type: VIEW; Schema: public; Owner: cocacola
--

CREATE VIEW vw_user_scoreboard AS
 SELECT u.id,
    u.app_code,
    (((u.name)::text || ' '::text) || (u.surname)::text) AS name,
    u.team_code,
    u.area_code,
    u.points,
    (round(u.seconds))::integer AS seconds,
    ((u.curr_game_id - 1) / 2) AS games,
        CASE
            WHEN (u.seconds <> (0)::double precision) THEN round((((u.points)::double precision / u.seconds))::numeric, 2)
            ELSE 0.0
        END AS coins
   FROM vw_valid_user u;


ALTER TABLE vw_user_scoreboard OWNER TO cocacola;

--
-- Name: area id; Type: DEFAULT; Schema: public; Owner: cocacola
--

ALTER TABLE ONLY area ALTER COLUMN id SET DEFAULT nextval('area_id_seq'::regclass);


--
-- Name: game_action id; Type: DEFAULT; Schema: public; Owner: cocacola
--

ALTER TABLE ONLY game_action ALTER COLUMN id SET DEFAULT nextval('game_action_id_seq'::regclass);


--
-- Name: game_session id; Type: DEFAULT; Schema: public; Owner: cocacola
--

ALTER TABLE ONLY game_session ALTER COLUMN id SET DEFAULT nextval('game_session_id_seq'::regclass);


--
-- Name: point_multiplier id; Type: DEFAULT; Schema: public; Owner: cocacola
--

ALTER TABLE ONLY point_multiplier ALTER COLUMN id SET DEFAULT nextval('point_multiplier_id_seq'::regclass);


--
-- Name: team id; Type: DEFAULT; Schema: public; Owner: cocacola
--

ALTER TABLE ONLY team ALTER COLUMN id SET DEFAULT nextval('team_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: cocacola
--

ALTER TABLE ONLY "user" ALTER COLUMN id SET DEFAULT nextval('user_id_seq'::regclass);


--
-- Data for Name: area; Type: TABLE DATA; Schema: public; Owner: cocacola
--

COPY area (id, code, points, seconds) FROM stdin;
26	NO_AREA	0	0
27	modena	0	0
28	Formigine	0	0
29		0	0
30	area03	0	0
\.


--
-- Name: area_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cocacola
--

SELECT pg_catalog.setval('area_id_seq', 30, true);


--
-- Data for Name: game_action; Type: TABLE DATA; Schema: public; Owner: cocacola
--

COPY game_action (id, game_id, item_id, user_id, occurred_at, points, team_code, area_code) FROM stdin;
\.


--
-- Name: game_action_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cocacola
--

SELECT pg_catalog.setval('game_action_id_seq', 4077, true);


--
-- Data for Name: game_session; Type: TABLE DATA; Schema: public; Owner: cocacola
--

COPY game_session (id, user_id, game_id, started_at, refreshed_at, team_code, area_code) FROM stdin;
\.


--
-- Name: game_session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cocacola
--

SELECT pg_catalog.setval('game_session_id_seq', 584, true);


--
-- Data for Name: point_multiplier; Type: TABLE DATA; Schema: public; Owner: cocacola
--

COPY point_multiplier (id, user_id, team_code, area_code, multiplier, created_at, special_game_id) FROM stdin;
1	1031	team03	area03	1	2017-07-25 08:01:06	1
3	1031	team03	area03	1	2017-07-25 08:34:41	2
4	1031	team03	area03	1	2017-07-25 08:51:35	3
5	1031	team03	area03	1.19999999999999996	2017-07-25 08:51:50	4
6	1031	team03	area03	1.19999999999999996	2017-07-25 08:52:25	5
17	1032	team03	area03	1.19999999999999996	2017-08-01 19:22:57	13
\.


--
-- Name: point_multiplier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cocacola
--

SELECT pg_catalog.setval('point_multiplier_id_seq', 17, true);


--
-- Data for Name: team; Type: TABLE DATA; Schema: public; Owner: cocacola
--

COPY team (id, code, points, seconds, area_code) FROM stdin;
47	NO_TEAM	0	0	NO_AREA
48	twistedmirror	0	0	modena
49	LAGroup	0	0	Formigine
50		0	0	
51	team03	362	0	area03
\.


--
-- Name: team_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cocacola
--

SELECT pg_catalog.setval('team_id_seq', 51, true);


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: cocacola
--

COPY "user" (id, name, surname, app_code, team_code, area_code, role, curr_game_id, seconds, points, curr_special_game_id) FROM stdin;
1036			7d6c66541263			3	1	0	0	1
1038			e22715bf71f4			3	1	0	0	1
1039			5febb69594be			3	1	0	0	1
1040			1a28f466844a			3	1	0	0	1
1042			87dd314f8f3b			3	1	0	0	1
1043			6814b5529428			3	1	0	0	1
1044			aa72077b5c08			3	1	0	0	1
1046			9e13f7fd347d			3	1	0	0	1
1047			e72cf820e949			3	1	0	0	1
1048			e8154809d0bd			3	1	0	0	1
1050			b5669a172337			3	1	0	0	1
1051			e4547ad49e9a			3	1	0	0	1
1052			cff10b4f3dcb			2	1	0	0	1
1054			4acaf44b497c			2	1	0	0	1
1055			881de6a99576			2	1	0	0	1
1056			64ec7079c146			2	1	0	0	1
1058			c35a0fa8eb33			2	1	0	0	1
1059			978a11783250			2	1	0	0	1
1061			71a14450d460			2	1	0	0	1
1062			117f0d839650			2	1	0	0	1
1063			d2131a594be8			2	1	0	0	1
1065			e7ec22b4a2f0			2	1	0	0	1
1066			e3650dff678e			2	1	0	0	1
1067			531fddead41e			2	1	0	0	1
1069			9ccfefa6563d			2	1	0	0	1
1070			3a85c94abd65			2	1	0	0	1
1071			9f3237602a72			2	1	0	0	1
1073			b9e575163c15			2	1	0	0	1
1074			6689da6a963d			2	1	0	0	1
1075			732d17bf6bfe			2	1	0	0	1
1077			72f83a28e275			2	1	0	0	1
1078			dee5fe0206fd			2	1	0	0	1
1079			8921efb0309e			2	1	0	0	1
1081			a94664acde33			2	1	0	0	1
1082			b2602206fdb7			2	1	0	0	1
1083			c73186c71060			2	1	0	0	1
1085			2cdf82326421			2	1	0	0	1
1086			516a44501677			2	1	0	0	1
1091			c32bf8d3c7bb			2	1	0	0	1
1092			a47e2689de03			2	1	0	0	1
1094			46bb52cf1577			2	1	0	0	1
1095			79a1c9fa11fa			2	1	0	0	1
1096			8426990a4db7			2	1	0	0	1
1098			49dd041ab495			2	1	0	0	1
1099			43fd2ef4541a			2	1	0	0	1
1100			4b2245dc806c			2	1	0	0	1
1102			ebf4e8d831ae			2	1	0	0	1
1103			bac84645d228			2	1	0	0	1
1104			b24e194b1bbf			2	1	0	0	1
1106			af2f4b4de899			2	1	0	0	1
1107			e53eca12e6a9			2	1	0	0	1
1108			90ff768c8f84			2	1	0	0	1
1110			ce18bef12855			2	1	0	0	1
1111			d3d05f9e6b61			2	1	0	0	1
1113			a2b5cb7ca49c			2	1	0	0	1
1114			e8ed19b64120			2	1	0	0	1
1115			0ec4c459c586			2	1	0	0	1
1117			572bf9fdbda1			2	1	0	0	1
1118			3107ce75d65e			2	1	0	0	1
1119			e2ef546a9b66			2	1	0	0	1
1121			1faf048d1429			2	1	0	0	1
1122			a52b403c8944			2	1	0	0	1
1123			fea7dbf1ddd4			2	1	0	0	1
1125			93eb0e9caaaf			2	1	0	0	1
1126			25ba422eeb87			2	1	0	0	1
1127			f068d0eebd78			2	1	0	0	1
1129			1c314c66aaa0			2	1	0	0	1
1130			1e9c4d73dfbc			2	1	0	0	1
1131			99741e271d7e			2	1	0	0	1
1133			fe9941df274b			2	1	0	0	1
1134			d7ea7f1fa564			2	1	0	0	1
1135			cf6fc4cebe66			2	1	0	0	1
1137			7cdc9d587a0e			2	1	0	0	1
1138			5a3e089db2d6			2	1	0	0	1
1140			0407eff3900d			2	1	0	0	1
1141			ce95694523fc			2	1	0	0	1
1142			4287f945b65e			2	1	0	0	1
1144			76b57ba05a3d			2	1	0	0	1
1145			bffbf839c731			2	1	0	0	1
1146			f93717fdf184			2	1	0	0	1
1148			f959e87479e1			2	1	0	0	1
1149			9bfbaff091b1			2	1	0	0	1
1150			91f83f342871			2	1	0	0	1
1152			37c48190a0c1			2	1	0	0	1
1153			38f3410236d4			2	1	0	0	1
1154			b86755a376c7			2	1	0	0	1
1156			aa89d4d1f579			2	1	0	0	1
1157			c9742e9b8411			2	1	0	0	1
1158			6f684bd54390			2	1	0	0	1
1160			8335f969caa4			2	1	0	0	1
1161			9823ad34cd4b			2	1	0	0	1
1162			6064d9e408de			2	1	0	0	1
1164			b2553c632840			2	1	0	0	1
1165			de60dc1c6313			2	1	0	0	1
1167			7b0cd420745a			2	1	0	0	1
1168			4b14c49da428			2	1	0	0	1
1169			48834051511e			2	1	0	0	1
1171			3ad4ac1814e6			2	1	0	0	1
1172			96469607ba77			2	1	0	0	1
1173			e730fb9bea66			2	1	0	0	1
1175			7ca807371a9f			2	1	0	0	1
1176			2130f04a5815			2	1	0	0	1
1177			d360d67a38da			2	1	0	0	1
1179			555499a4831d			2	1	0	0	1
1180			0634d3681c7f			2	1	0	0	1
1181			0b18cbf58587			2	1	0	0	1
1183			0d1fd6f48932			1	1	0	0	1
1184			62e1e9a490fd			1	1	0	0	1
1188			e1721c07928b			1	1	0	0	1
1189			6109bec74d12			1	1	0	0	1
1191			f4c737237a66			1	1	0	0	1
1192			50dbb1d69039			1	1	0	0	1
1193			1cdf6d373ea8			1	1	0	0	1
1195			42f4e6b15c31			1	1	0	0	1
1196			b52041b6ec81			1	1	0	0	1
1197			597d12ae9adb			1	1	0	0	1
1199			0643678f42f2			1	1	0	0	1
1200			a95910f6cc26			1	1	0	0	1
1201			084bcc8400ef			1	1	0	0	1
1203			3c23afcacb40			1	1	0	0	1
1204			cf21dc2b024e			1	1	0	0	1
1205			b2f9e753d845			1	1	0	0	1
1207			c4e697992e99			1	1	0	0	1
1208			318be25a51ce			1	1	0	0	1
1210			9e09d8f741e0			1	1	0	0	1
1211			bb1aeb37b754			1	1	0	0	1
1212			2fdc9acce5aa			1	1	0	0	1
1214			ccd02155cc12			1	1	0	0	1
1215			ac09303bf9f3			1	1	0	0	1
1216			2ad095962672			1	1	0	0	1
1218			5ee7b911f88c			1	1	0	0	1
1219			a3903f35ed55			1	1	0	0	1
1220			ac228ee8991b			1	1	0	0	1
1222			753d645a1fdc			1	1	0	0	1
1223			8c370b9c7f20			1	1	0	0	1
1224			6ae4191b9605			1	1	0	0	1
1226			61b4312a9f37			1	1	0	0	1
1227			629a5c2653b7			1	1	0	0	1
1228			2520f4c6662f			1	1	0	0	1
1230			92f075bbdd93			1	1	0	0	1
1231			75bc78f59802			1	1	0	0	1
1232			7834993cbd81			1	1	0	0	1
1234			cf47fa4eb561			1	1	0	0	1
1235			41f52e2e1d41			1	1	0	0	1
1237			1f55709d539c			1	1	0	0	1
1238			4bc8b45ef3f7			1	1	0	0	1
1239			2dd3b4a332fc			1	1	0	0	1
1241			f120f3b74c97			1	1	0	0	1
1242			612f8fa2ba46			1	1	0	0	1
1243			b3c82d2b11ee			1	1	0	0	1
1245			440f95a33de4			1	1	0	0	1
1246			883d0228357a			1	1	0	0	1
1247			9102236bea2d			1	1	0	0	1
1249			ceeea00f602a			1	1	0	0	1
1250			dc8739cdcd97			1	1	0	0	1
1251			7cc0592b81f4			1	1	0	0	1
1253			eef3561e2fd0			1	1	0	0	1
1254			4e453181ca6d			1	1	0	0	1
1255			c99c8287acf8			1	1	0	0	1
1257			77246bdf2259			1	1	0	0	1
1258			0b6ccdb282bc			1	1	0	0	1
1259			e2337f808fde			1	1	0	0	1
1261			9f96aabd2006			1	1	0	0	1
1262			cf3ca0ef7680			1	1	0	0	1
1264			277012a6de0a			1	1	0	0	1
1265			659f38af3081			1	1	0	0	1
1266			2d8491b22e5b			1	1	0	0	1
1268			6f4cd884b700			1	1	0	0	1
1269			4e1be5610e4f			1	1	0	0	1
1270			238c5bad7233			1	1	0	0	1
1272			734363e8e2d2			1	1	0	0	1
1273			d1a9296d4080			1	1	0	0	1
1274			9d3249368d18			1	1	0	0	1
1276			b4886917cdd3			1	1	0	0	1
1277			3227f047e151			1	1	0	0	1
1278			a7ee503d8b66			1	1	0	0	1
1280			98c7d981d0b2			1	1	0	0	1
1281			6645370a697e			1	1	0	0	1
1285			107511ee2a3c			1	1	0	0	1
1286			1d9d790bb6e1			1	1	0	0	1
1288			a776b0367d7d			1	1	0	0	1
1289			241ec8bf2350			1	1	0	0	1
1290			5c51a11dedb2			1	1	0	0	1
1292			f7607985283d			1	1	0	0	1
1293			03aae6839409			1	1	0	0	1
1294			e85d3f9a1aa8			1	1	0	0	1
1296			7d7961e043dd			1	1	0	0	1
1297			1ca0f5be80cf			1	1	0	0	1
1298			f8161c11c64a			1	1	0	0	1
1300			940a019db648			1	1	0	0	1
1301			4d2d75c328f4			1	1	0	0	1
1302			153a529fd606			1	1	0	0	1
1304			bbc6daff8044			1	1	0	0	1
1305			0fb453246d31			1	1	0	0	1
1307			38130a5eea68			1	1	0	0	1
1308			08e57f7473c1			1	1	0	0	1
1309			faacae1138aa			1	1	0	0	1
1311			a525a61bba92			1	1	0	0	1
1312			66e5f0303fa1			1	1	0	0	1
1313			d2687676bd09			1	1	0	0	1
1315			2843a5f5f387			1	1	0	0	1
1316			13c7fc8c371c			1	1	0	0	1
1317			377f50c1e5d4			1	1	0	0	1
1319			0e3a8d89b7bd			1	1	0	0	1
1320			a2b319139789			1	1	0	0	1
1321			9909ac3b2a50			1	1	0	0	1
1323			1c69818741a8			1	1	0	0	1
1324			095811b61970			1	1	0	0	1
1325			322da3a7eaf8			1	1	0	0	1
1327			12ee9cdf1a69			1	1	0	0	1
1328			5b0e5cb57410			1	1	0	0	1
1329			594a6ca82071			1	1	0	0	1
1331			775b6acb5b04			1	1	0	0	1
1332			abb03e35a901			1	1	0	0	1
1334			93e26c38dac0			1	1	0	0	1
1335			db54ee969434			1	1	0	0	1
1336			59a450e8f836			1	1	0	0	1
1338			9fb8870900f6			1	1	0	0	1
1339			7c0529aa1bf6			1	1	0	0	1
1340			f234ef502e59			1	1	0	0	1
1342			ee2d28d783cc			1	1	0	0	1
1343			558b1f0fe630			1	1	0	0	1
1344			adb8facad0be			1	1	0	0	1
1346			b3e63935b88d			1	1	0	0	1
1347			e77ca7399b5b			1	1	0	0	1
1348			6a3eb5048568			1	1	0	0	1
1350			24b54aec6eb0			1	1	0	0	1
1351			ee141a511c25			1	1	0	0	1
1352			5f89daaa4d73			1	1	0	0	1
1354			74fb8f8b24d1			1	1	0	0	1
1355			163f048d4071			1	1	0	0	1
1356			1a405d593fa4			1	1	0	0	1
1358			429afb87bc5e			1	1	0	0	1
1359			dc3afdc7e06e			1	1	0	0	1
1361			0f185a6b9983			1	1	0	0	1
1362			9e66ac05fdb6			1	1	0	0	1
1363			26408941b969			1	1	0	0	1
1365			2fcc9c3c0b14			1	1	0	0	1
1366			86147b7cf993			1	1	0	0	1
1367			f644b100203a			1	1	0	0	1
1369			8281b14195fa			1	1	0	0	1
1370			6c69ad1f3b02			1	1	0	0	1
1371			6c004edb1c2e			1	1	0	0	1
1373			30c9adf4576a			1	1	0	0	1
1374			625be31ff533			1	1	0	0	1
1375			2392999b49ea			1	1	0	0	1
1377			d4b2cd302179			1	1	0	0	1
1378			5691781f256d			1	1	0	0	1
1382			79facac9283a			1	1	0	0	1
1383			013133140325			1	1	0	0	1
1385			7f5d7526a877			1	1	0	0	1
1386			571e9791a5e1			1	1	0	0	1
1387			e0c8f8e72c7d			1	1	0	0	1
1389			9c249d50d78f			1	1	0	0	1
1390			4623cc4fb684			1	1	0	0	1
1391			71995079ba6d			1	1	0	0	1
1393			9f36bf9e80cd			1	1	0	0	1
1394			79322d1285ea			1	1	0	0	1
1395			55cf55b64879			1	1	0	0	1
1397			91d5fe4d7eeb			1	1	0	0	1
1398			f156fa463dd6			1	1	0	0	1
1399			053a74513ae1			1	1	0	0	1
1401			022a222d435b			1	1	0	0	1
1402			917101f18593			1	1	0	0	1
1404			8b4d9d4313af			1	1	0	0	1
1405			be2ff630f0c8			1	1	0	0	1
1406			6a67dd3c8116			1	1	0	0	1
1408			a7436c3afc38			1	1	0	0	1
1409			2706d2b85b9f			1	1	0	0	1
1410			d979cd1b670a			1	1	0	0	1
1412			08fe85353927			1	1	0	0	1
1413			95b5f5bd4b96			1	1	0	0	1
1414			6b426fca678e			1	1	0	0	1
1416			a2be8ea5ada8			1	1	0	0	1
1417			fdee7045b05f			1	1	0	0	1
1418			052d743347c2			1	1	0	0	1
1420			6418f3e054ea			1	1	0	0	1
1421			4f329f3ce9e5			1	1	0	0	1
1422			a0af39ec2ee2			1	1	0	0	1
1424			ef3c6b2a6659			1	1	0	0	1
1425			77fcd375e4f7			1	1	0	0	1
1426			72ec6b8461f8			1	1	0	0	1
1428			caa3a0a7b198			1	1	0	0	1
1429			d3fa4b408e2a			1	1	0	0	1
1431			6836a7a44e84			1	1	0	0	1
1432			952954f18c34			1	1	0	0	1
1433			6f9c67a43834			1	1	0	0	1
1435			b2907935e660			1	1	0	0	1
1436			5e95561ab887			1	1	0	0	1
1437			219579ae0158			1	1	0	0	1
1439			138740fcf6f0			1	1	0	0	1
1440			bf32fd2d3320			1	1	0	0	1
1441			738fa563659b			1	1	0	0	1
1443			b9eb79a5144f			1	1	0	0	1
1444			d6b9e25ca3f7			1	1	0	0	1
1445			37e3730d79ce			1	1	0	0	1
1447			6f2eeec2a956			1	1	0	0	1
1448			bc8554290076			1	1	0	0	1
1449			224d8776a162			1	1	0	0	1
1451			077b1610fd1c			1	1	0	0	1
1452			8715c169a284			1	1	0	0	1
1453			708df70ceb30			1	1	0	0	1
1455			6ea61c3cd5af			1	1	0	0	1
1456			685cc24fb406			1	1	0	0	1
1458			34225371c368			1	1	0	0	1
1459			c42e78bc73c4			1	1	0	0	1
1460			25e97f83b340			1	1	0	0	1
1462			c06c737729b9			1	1	0	0	1
1463			c02983b7b8b8			1	1	0	0	1
1464			ac9582aa2bde			1	1	0	0	1
1466			bf98ef9d9154			1	1	0	0	1
1467			476ed1a1cb67			1	1	0	0	1
1468			045ece1b2628			1	1	0	0	1
1470			a5f24f3c1db8			1	1	0	0	1
1471			84a040604cdd			1	1	0	0	1
1472			c26c946c9bda			1	1	0	0	1
1474			fbfa6b9a36f4			1	1	0	0	1
1475			be23dc8c9c0d			1	1	0	0	1
1037			505e93d72c8b			3	1	0	0	1
1041			e17745b5da77			3	1	0	0	1
1045			7b2e95d9cd1c			3	1	0	0	1
1049			9b5cf2bcdbc3			3	1	0	0	1
1053			25ae31a445a1			2	1	0	0	1
1057			1bd8e4bf2925			2	1	0	0	1
1060			e703abbc93f7			2	1	0	0	1
1064			cb6c79794ee3			2	1	0	0	1
1068			fa81b765b6b5			2	1	0	0	1
1072			20750435bfc4			2	1	0	0	1
1477			ea26c9da621c			1	1	0	0	1
1478			297aba814d31			1	1	0	0	1
1479			fd624240f212			1	1	0	0	1
1481			931ed1d09760			1	1	0	0	1
1482			d46ac012d01d			1	1	0	0	1
1483			8eee43601bc1			1	1	0	0	1
1485			f97449bca663			1	1	0	0	1
1486			40308fcc1541			1	1	0	0	1
1487			df028701e0ea			1	1	0	0	1
1489			f1d9b4ddeae7			1	1	0	0	1
1490			177a15d2253c			1	1	0	0	1
1492			87ed8b95b87b			1	1	0	0	1
1493			ad672f9b367a			1	1	0	0	1
1494			e4db9f197ac0			1	1	0	0	1
1076			96d2d9962e06			2	1	0	0	1
1080			a29daec9ae29			2	1	0	0	1
1084			b46db24c217d			2	1	0	0	1
1087			fc680dd24999			2	1	0	0	1
1088			1a83a9ab0f57			2	1	0	0	1
1089			6a2d84682f80			2	1	0	0	1
1093			dbfcaa24e14b			2	1	0	0	1
1097			59ad5a101aab			2	1	0	0	1
1101			f14a465d41db			2	1	0	0	1
1105			7cb16e91468e			2	1	0	0	1
1109			07e675b356db			2	1	0	0	1
1112			a9d33ff78865			2	1	0	0	1
1116			3b1f4f1f9691			2	1	0	0	1
1120			22a97b883fbd			2	1	0	0	1
1124			b88685cffa58			2	1	0	0	1
1128			b76186333457			2	1	0	0	1
1132			3e7594c095bb			2	1	0	0	1
1136			e08782565836			2	1	0	0	1
1139			418817196509			2	1	0	0	1
1143			9c7399e8cb3a			2	1	0	0	1
1147			8d954790ac8e			2	1	0	0	1
1151			a61326f263b0			2	1	0	0	1
1155			76fddcab754c			2	1	0	0	1
1159			7acad02e056d			2	1	0	0	1
1163			53747337645d			2	1	0	0	1
1166			68b19962017c			2	1	0	0	1
1170			73cd6a6345bc			2	1	0	0	1
1174			bd26fd397f83			2	1	0	0	1
1178			9ff20bd7cd75			2	1	0	0	1
1182			754f03bcbb34			2	1	0	0	1
1185			a049564bfbc8			1	1	0	0	1
1186			50858b9060ba			1	1	0	0	1
1190			56d8b6c46544			1	1	0	0	1
1194			22b00f7218aa			1	1	0	0	1
1198			9702431d600c			1	1	0	0	1
1202			da18bebb6361			1	1	0	0	1
1206			bd44e521f36b			1	1	0	0	1
1209			c4c6cdb9da45			1	1	0	0	1
1213			b8845a9c2d7f			1	1	0	0	1
1217			90803a88c87b			1	1	0	0	1
1221			149c1380f13f			1	1	0	0	1
1225			53f7875f43d1			1	1	0	0	1
1229			a98122063507			1	1	0	0	1
1233			5f91fd0057ca			1	1	0	0	1
1236			790a4d905294			1	1	0	0	1
1240			c0a8c6b2f535			1	1	0	0	1
1244			212959440fc0			1	1	0	0	1
1248			4795303ab86f			1	1	0	0	1
1252			527e118e3ec2			1	1	0	0	1
1256			8a79be5ad074			1	1	0	0	1
1260			a4b8792edaea			1	1	0	0	1
1263			15e8736e5977			1	1	0	0	1
1267			595a6d4b6b00			1	1	0	0	1
1271			9c432188cb0f			1	1	0	0	1
1275			cdcd7a1818c6			1	1	0	0	1
1279			ec9d3277cd1f			1	1	0	0	1
1282			e3f5854fdb73			1	1	0	0	1
1283			67c243476e50			1	1	0	0	1
1287			3a71a639f479			1	1	0	0	1
1291			335f7f59bdc5			1	1	0	0	1
1295			55dbacf21218			1	1	0	0	1
1299			40a2bd17d17f			1	1	0	0	1
1303			e93bcba0b6e4			1	1	0	0	1
1306			5b0d3758a719			1	1	0	0	1
1310			d7eee1deb737			1	1	0	0	1
1314			9368c1377212			1	1	0	0	1
1318			ff452594c801			1	1	0	0	1
1322			fa25b52bf69f			1	1	0	0	1
1326			219d7b9a0075			1	1	0	0	1
1330			7805853006e2			1	1	0	0	1
1333			1c49fecffaa6			1	1	0	0	1
1337			e370b7f2a394			1	1	0	0	1
1341			7047ee9e57ee			1	1	0	0	1
1345			832b5cf1ab3e			1	1	0	0	1
1349			733323515415			1	1	0	0	1
971			9dbf77223bc8			2	1	0	0	1
972			92f06ec6ae9a			2	1	0	0	1
973			bfcc57abf4cb			2	1	0	0	1
974			ac2fcfefa605			2	1	0	0	1
975			f417bd0de426			2	1	0	0	1
976			3a944b415edc			2	1	0	0	1
977			952a63af184d			2	1	0	0	1
978			a30dd48bf192			2	1	0	0	1
979			93de3a6f099f			2	1	0	0	1
980			90cd0b69b42a			2	1	0	0	1
981			a93dd78611e5			2	1	0	0	1
982			8d9d01149781			2	1	0	0	1
983			53348603a45a			2	1	0	0	1
984			b7a6fbb94683			2	1	0	0	1
985			afcbfda0e69a			2	1	0	0	1
986			f80af9e4bed5			2	1	0	0	1
987			f582ed57949a			2	1	0	0	1
1			90a409ff0973			4	1	0	0	1
2			48c339856288			1	1	0	0	1
3			9aa0cfbdd2f2			1	1	0	0	1
5			5d97a62424f9			1	1	0	0	1
6			20301855e857			1	1	0	0	1
7			427672da5bc7			1	1	0	0	1
8			a288d1d5dcbb			1	1	0	0	1
9			491a33229b08			1	1	0	0	1
11			a9e9d88e3c6f			1	1	0	0	1
12			deb5b53f04b0			1	1	0	0	1
13			2cde744c9802			1	1	0	0	1
14			c149f7425759			1	1	0	0	1
15			8c8b4d253c47			1	1	0	0	1
16			ec166bac926f			1	1	0	0	1
17			f7a9ed8740cf			1	1	0	0	1
18			08e3824c8d19			1	1	0	0	1
19			31adf4366e4c			1	1	0	0	1
20			ac1cc13f10be			1	1	0	0	1
21			9c42a14a7d9c			1	1	0	0	1
22			264b53bc5588			1	1	0	0	1
23			201e5a70b54b			1	1	0	0	1
24			7a42f964f9eb			1	1	0	0	1
25			14be4f2a6fad			1	1	0	0	1
26			017059abc14a			1	1	0	0	1
27			ad46e5d7a435			1	1	0	0	1
28			1d42a154d2c1			1	1	0	0	1
29			a80f951239a5			1	1	0	0	1
30			41e9edb1cc85			1	1	0	0	1
32			981a2452f9cc			1	1	0	0	1
33			a1fc174c79e6			1	1	0	0	1
34			5e228070b13e			1	1	0	0	1
35			a5b89bec031b			1	1	0	0	1
36			bbe359cdde30			1	1	0	0	1
37			65be21e26ed1			1	1	0	0	1
38			dbb6b3750d83			1	1	0	0	1
39			913a3f162947			1	1	0	0	1
40			5c1a753f93bf			1	1	0	0	1
41			c9e1ce63254f			1	1	0	0	1
42			166b62fa8140			1	1	0	0	1
43			f17e64d04bb4			1	1	0	0	1
44			9e4fffe0cef8			1	1	0	0	1
45			225fd0f2971c			1	1	0	0	1
46			c30470579c34			1	1	0	0	1
47			5d5cbd1869e5			1	1	0	0	1
48			9fc90dbdc067			1	1	0	0	1
49			78c982a7dbd5			1	1	0	0	1
50			2f038e5e66f7			1	1	0	0	1
51			41552ef64ac1			1	1	0	0	1
53			6dfbf5f0f8f8			1	1	0	0	1
54			b3a192ce524f			1	1	0	0	1
55			be93acab2bb9			1	1	0	0	1
56			669ddc08c6eb			1	1	0	0	1
57			20fc1b4c05aa			1	1	0	0	1
58			c6755ffa07ba			1	1	0	0	1
59			592d83f5e4da			1	1	0	0	1
60			98af081f9cf4			1	1	0	0	1
61			774bb53481e3			1	1	0	0	1
62			0cab66751e54			1	1	0	0	1
63			b114568506a5			1	1	0	0	1
64			f413d17e0bf5			1	1	0	0	1
65			8cc9c640dc70			1	1	0	0	1
66			abc44dfc5127			1	1	0	0	1
67			02c42e7a6817			1	1	0	0	1
68			d156f2c18d69			1	1	0	0	1
69			7bbce9e5b2f7			1	1	0	0	1
70			e28347ab2ca8			1	1	0	0	1
71			367a8f907d49			1	1	0	0	1
72			79bf359895a3			1	1	0	0	1
74			6f9d9fffff44			1	1	0	0	1
75			5befa7af798c			1	1	0	0	1
76			a0b7e0fbb9b0			1	1	0	0	1
77			c571780db32f			1	1	0	0	1
78			43662c7964aa			1	1	0	0	1
79			d0d8ce5c8c1b			1	1	0	0	1
80			5510ce153f29			1	1	0	0	1
81			6b4abab1b6e1			1	1	0	0	1
82			7f0ce5b1f1e9			1	1	0	0	1
83			188b77b4599a			1	1	0	0	1
84			77617279c5ee			1	1	0	0	1
85			9896707d528e			1	1	0	0	1
86			20789a3a05f1			1	1	0	0	1
87			bb8d0be33606			1	1	0	0	1
88			6fb2a52fe127			1	1	0	0	1
89			72b79a870936			1	1	0	0	1
90			3755ff1f275f			1	1	0	0	1
91			c31e2fae9a6e			1	1	0	0	1
92			30170555c7cc			1	1	0	0	1
93			6e4a2ad29743			1	1	0	0	1
95			181856e9a38c			1	1	0	0	1
96			50cbdb69755f			1	1	0	0	1
97			e6fa0f416959			1	1	0	0	1
98			bc9c3aa6b046			1	1	0	0	1
99			697bafd1852a			1	1	0	0	1
100			69fc38657a8e			1	1	0	0	1
102			95cf1ad170bd			1	1	0	0	1
103			b05b6ed44f70			1	1	0	0	1
104			bf04bce53203			1	1	0	0	1
105			35f1f6214987			1	1	0	0	1
106			8fb59f073664			1	1	0	0	1
108			bb666889f0cd			1	1	0	0	1
109			9ee03d32e528			1	1	0	0	1
110			8af92ab36ed4			1	1	0	0	1
111			6c13de9fb517			1	1	0	0	1
112			490449c65cb4			1	1	0	0	1
113			56f2d0bfda6a			1	1	0	0	1
114			176f1a84d09c			1	1	0	0	1
115			6ef203dbc775			1	1	0	0	1
116			b485fef79ec4			1	1	0	0	1
117			2e6e4442a791			1	1	0	0	1
118			331cf1d70d24			1	1	0	0	1
119			77e2e4cd694d			1	1	0	0	1
120			ffac3558f8cc			1	1	0	0	1
121			59945359067f			1	1	0	0	1
122			7fc4a3ca7287			1	1	0	0	1
123			68fbd660495f			1	1	0	0	1
124			78836e8e9549			1	1	0	0	1
125			04dbd99b3176			1	1	0	0	1
126			ccef182520df			1	1	0	0	1
127			607d25d6e97b			1	1	0	0	1
129			011176ab2e15			1	1	0	0	1
130			e12fa1e75593			1	1	0	0	1
131			4d806c816ac7			1	1	0	0	1
132			87c190cf353a			1	1	0	0	1
133			3d10b35c5368			1	1	0	0	1
134			116934df0c5a			1	1	0	0	1
135			d1d64d85bff3			1	1	0	0	1
136			354ce77befc0			1	1	0	0	1
137			fde65bc46169			1	1	0	0	1
138			6f380884aa89			1	1	0	0	1
139			bbc61e97e81e			1	1	0	0	1
140			437dda91fa18			1	1	0	0	1
141			c1e59a28af1f			1	1	0	0	1
142			015729fb748f			1	1	0	0	1
143			1bd64cbf3b82			1	1	0	0	1
144			15ad45d7b4d1			1	1	0	0	1
145			82141bd03c2c			1	1	0	0	1
146			cc4f23ea4386			1	1	0	0	1
147			2fff1e4a20da			1	1	0	0	1
148			5980b9c7fcd0			1	1	0	0	1
150			2c1a2af2ce58			1	1	0	0	1
151			1e916dce5aff			1	1	0	0	1
152			4b8156748c8c			1	1	0	0	1
153			9883388f88f7			1	1	0	0	1
154			f1175a4b600c			1	1	0	0	1
155			14c719afd341			1	1	0	0	1
156			a0573a7345b1			1	1	0	0	1
157			d3ad91360db2			1	1	0	0	1
158			810bd1edd0ab			1	1	0	0	1
159			7649abe152db			1	1	0	0	1
160			f61de40748ce			1	1	0	0	1
161			59d038fdc105			1	1	0	0	1
162			15cf5296b70a			1	1	0	0	1
163			c228185ef5d2			1	1	0	0	1
164			62f751317f86			1	1	0	0	1
165			278e0f937adc			1	1	0	0	1
166			cfd5d50b1f66			1	1	0	0	1
167			f23165917d5c			1	1	0	0	1
168			b322391288fb			1	1	0	0	1
169			be959a9725f4			1	1	0	0	1
171			8eaffba40f21			1	1	0	0	1
172			3f99a81b67b3			1	1	0	0	1
173			1d3401d4ecdf			1	1	0	0	1
174			13b083ac2582			1	1	0	0	1
175			0a2466a277d2			1	1	0	0	1
176			d94c7e8fb50a			1	1	0	0	1
177			d4c194f43ac7			1	1	0	0	1
178			1d67ffcebf1c			1	1	0	0	1
179			872b41ee8504			1	1	0	0	1
180			29dc4783e2ea			1	1	0	0	1
181			d00b78e7ee1c			1	1	0	0	1
182			dea7e7737fc1			1	1	0	0	1
183			7077c7bdc620			1	1	0	0	1
184			0969cbb2942e			1	1	0	0	1
185			25c420c7e61c			1	1	0	0	1
186			acc7f3d5508f			1	1	0	0	1
187			77c83d33c16a			1	1	0	0	1
188			481e7fc862f0			1	1	0	0	1
189			850c65e54e49			1	1	0	0	1
190			27c81c41921c			1	1	0	0	1
192			e2c39f6ba781			1	1	0	0	1
193			8fd6319557e8			1	1	0	0	1
194			eecea915d202			1	1	0	0	1
195			79d6429e13ba			1	1	0	0	1
196			37863afec8c3			1	1	0	0	1
197			a671826f006e			1	1	0	0	1
199			1851f119597e			1	1	0	0	1
200			ec04debc6fc8			1	1	0	0	1
201			4a6b394fd38f			1	1	0	0	1
202			91b761c859a0			1	1	0	0	1
203			dfb79665ca7a			1	1	0	0	1
205			75c9e6cee123			1	1	0	0	1
206			c70c99eb5ddd			1	1	0	0	1
207			1653f1ac1bae			1	1	0	0	1
208			4308f00cd3d0			1	1	0	0	1
209			45ee87ab5a3c			1	1	0	0	1
210			934a5c387cdf			1	1	0	0	1
211			2ff9d23f3945			1	1	0	0	1
212			44c1e03fee9c			1	1	0	0	1
213			baaa77c78132			1	1	0	0	1
214			81b170a610a9			1	1	0	0	1
215			04e8f481bfe7			1	1	0	0	1
216			a1c045c6cb26			1	1	0	0	1
217			0f1cce3900f8			1	1	0	0	1
218			10d45fbb9e35			1	1	0	0	1
219			aa7728c6ea19			1	1	0	0	1
220			c29a625f2d6b			1	1	0	0	1
221			29a606ebe317			1	1	0	0	1
222			41ab71c0a8a3			1	1	0	0	1
223			70195fbccac5			1	1	0	0	1
224			c82d8eff5072			1	1	0	0	1
226			046ddb70f599			1	1	0	0	1
227			4b5fb40ccfd5			1	1	0	0	1
228			8007a416f66c			1	1	0	0	1
229			2b1c0c416545			1	1	0	0	1
230			9f7ff62e6070			1	1	0	0	1
231			57ec5266e250			1	1	0	0	1
232			6ff8397e59c4			1	1	0	0	1
233			bd219e777656			1	1	0	0	1
234			121f73f083e2			1	1	0	0	1
235			cd5693c188ed			1	1	0	0	1
236			378cb7e053c2			1	1	0	0	1
237			48ac0fcd165a			1	1	0	0	1
238			59830aa52d7a			1	1	0	0	1
239			1403f515ccbf			1	1	0	0	1
240			45a6694470f1			1	1	0	0	1
241			feebea26af8d			1	1	0	0	1
242			284562448d17			1	1	0	0	1
243			29fe5b578380			1	1	0	0	1
244			ae0a4dec43d0			1	1	0	0	1
245			15d82fc0bc01			1	1	0	0	1
247			188dd41734d3			1	1	0	0	1
248			377564b8f4d2			1	1	0	0	1
249			410a2cd44800			1	1	0	0	1
250			1ba3dc7c6a91			1	1	0	0	1
251			d49f80902c10			1	1	0	0	1
252			5b1c47013bd7			1	1	0	0	1
253			9bccc411ba90			1	1	0	0	1
254			a23d6659877c			1	1	0	0	1
255			bba97818e105			1	1	0	0	1
256			07dc23686c96			1	1	0	0	1
257			1c2612db5457			1	1	0	0	1
258			3b643a0d26a2			1	1	0	0	1
259			c7feeed90f39			1	1	0	0	1
260			f515cf1f4cb5			1	1	0	0	1
261			4b284d5fd2bd			1	1	0	0	1
262			0fbaf18d8062			1	1	0	0	1
263			a9b8fafdf675			1	1	0	0	1
264			1c9a30a6677e			1	1	0	0	1
265			497d958d445f			1	1	0	0	1
266			f8e675add6cc			1	1	0	0	1
268			39d683b12672			1	1	0	0	1
269			2e127fbba9a6			1	1	0	0	1
270			388db1d6921e			1	1	0	0	1
271			f56096c9c14c			1	1	0	0	1
272			5bc03c68c957			1	1	0	0	1
273			e0411d2d7e24			1	1	0	0	1
274			251d345d0115			1	1	0	0	1
275			bda75846ed60			1	1	0	0	1
276			7b4b41a4ee51			1	1	0	0	1
277			b792fc7183ce			1	1	0	0	1
278			1431535e0d27			1	1	0	0	1
279			4206ffb8cfd3			1	1	0	0	1
280			babdf0252f6c			1	1	0	0	1
281			4ab9b64f4f7b			1	1	0	0	1
282			cb9736a3f2be			1	1	0	0	1
283			e04306d8187d			1	1	0	0	1
284			c3fe6126af1a			1	1	0	0	1
285			0ec4513fe093			1	1	0	0	1
286			9f6c9a1b7979			1	1	0	0	1
287			d1d1369ecf46			1	1	0	0	1
289			1984fe1c625f			1	1	0	0	1
290			a3ec43f773cd			1	1	0	0	1
291			628e89905593			1	1	0	0	1
292			179883fa6221			1	1	0	0	1
293			b554075b9e92			1	1	0	0	1
294			1f45177a561e			1	1	0	0	1
296			42d3db4b4850			1	1	0	0	1
297			e6957cbdd930			1	1	0	0	1
298			6ef4c78bf0b5			1	1	0	0	1
299			28c046008763			1	1	0	0	1
300			ac3598ee7586			1	1	0	0	1
302			71230f598f58			1	1	0	0	1
303			53a79bded295			1	1	0	0	1
304			0101f222ff1f			1	1	0	0	1
305			9f210c88bc24			1	1	0	0	1
306			fee9093d48df			1	1	0	0	1
307			ff980ced863c			1	1	0	0	1
308			a990278d7e71			1	1	0	0	1
309			3698ce07177a			1	1	0	0	1
310			dda5444b0177			1	1	0	0	1
311			f19807c959a3			1	1	0	0	1
312			c2023f390585			1	1	0	0	1
313			9ed50b874a2a			1	1	0	0	1
314			5f7c64a64f57			1	1	0	0	1
315			7b5838beab9e			1	1	0	0	1
316			2146798db313			1	1	0	0	1
317			46df81e79b71			1	1	0	0	1
318			d4e129a65470			1	1	0	0	1
319			1259beec9037			1	1	0	0	1
320			e48daab76e68			1	1	0	0	1
321			7cd08d215fbd			1	1	0	0	1
323			ba718b5e7ecf			1	1	0	0	1
324			20275bd7298d			1	1	0	0	1
325			82e1cb274d46			1	1	0	0	1
326			d9ca9255ca3c			1	1	0	0	1
327			baa8b8f8acab			1	1	0	0	1
328			a93a5e74c4a4			1	1	0	0	1
329			3123c665cfdb			1	1	0	0	1
330			7dd80936149e			1	1	0	0	1
331			fb0381055314			1	1	0	0	1
332			3f1add50b68d			1	1	0	0	1
333			b268c3e8c712			1	1	0	0	1
334			e415ecce90d8			1	1	0	0	1
335			40bdb37e50ce			1	1	0	0	1
336			7310f3f5cebb			1	1	0	0	1
337			78de534c7308			1	1	0	0	1
338			3b1e34c9c98f			1	1	0	0	1
339			69c3beae3dfc			1	1	0	0	1
340			94912d33a9a9			1	1	0	0	1
341			3a93dfbd3b0b			1	1	0	0	1
342			334e5fb1c871			1	1	0	0	1
344			923904ed6ae9			1	1	0	0	1
345			deecda6c5965			1	1	0	0	1
346			48e6b486f23c			1	1	0	0	1
347			a68a0580cc15			1	1	0	0	1
348			6f0f35c907b9			1	1	0	0	1
349			d8827971dbb9			1	1	0	0	1
350			168dedc903bc			1	1	0	0	1
351			6d61d3469c96			1	1	0	0	1
352			1137724a16db			1	1	0	0	1
353			65f0be638e8a			1	1	0	0	1
354			cf1c88a9c532			1	1	0	0	1
355			4d640e754d3d			1	1	0	0	1
356			c264bfbbc044			1	1	0	0	1
357			8daaa9e9939a			1	1	0	0	1
358			2a567f0080b9			1	1	0	0	1
359			1eccd9c15527			1	1	0	0	1
360			16db4309b934			1	1	0	0	1
361			0f3a43fb37f5			1	1	0	0	1
362			536ee1da0087			1	1	0	0	1
363			fe34ddb62e4d			1	1	0	0	1
365			f270713970c7			1	1	0	0	1
366			6410257ebc9a			1	1	0	0	1
367			6d6497a1038c			1	1	0	0	1
368			b8e9e1e5663c			1	1	0	0	1
369			041a0d61d532			1	1	0	0	1
370			e13f05899f2e			1	1	0	0	1
371			34582031c5aa			1	1	0	0	1
372			d2a8b22e64a1			1	1	0	0	1
373			25b19999aa69			1	1	0	0	1
374			09135a2484a0			1	1	0	0	1
375			1a197db524c3			1	1	0	0	1
376			9f5c496635db			1	1	0	0	1
377			b90e949f1a44			1	1	0	0	1
378			9f6bdfb76df9			1	1	0	0	1
379			6a903e65d0a8			1	1	0	0	1
380			e03fe960fc43			1	1	0	0	1
381			31b9d57633d0			1	1	0	0	1
382			29a2d844e778			1	1	0	0	1
383			30aa9eeffce4			1	1	0	0	1
384			5d2172ffd540			1	1	0	0	1
386			a0d777056f7d			1	1	0	0	1
387			11c08b6fa594			1	1	0	0	1
388			85418f8ba3d6			1	1	0	0	1
389			4d0ea1fa4610			1	1	0	0	1
390			427daed0e94e			1	1	0	0	1
391			f6ae95f1c968			1	1	0	0	1
393			9b864e303166			1	1	0	0	1
394			4ff0980a57e8			1	1	0	0	1
395			d1e2a06a0bf1			1	1	0	0	1
396			a0186c97319e			1	1	0	0	1
397			ea0f1e904973			1	1	0	0	1
399			420bf608aa6a			1	1	0	0	1
400			a2a60e0593e4			1	1	0	0	1
401			0866174c24b0			1	1	0	0	1
402			37d88fbdeb5b			1	1	0	0	1
403			19d993226d71			1	1	0	0	1
404			874814675e53			1	1	0	0	1
405			83a995dc1b04			1	1	0	0	1
406			1211ccceb56d			1	1	0	0	1
407			fb16ecd560d7			1	1	0	0	1
408			2a59d8d1ff7f			1	1	0	0	1
409			7d4b5618ec24			1	1	0	0	1
410			a5eeb37b82fb			1	1	0	0	1
411			53ac738d3ecb			1	1	0	0	1
412			0391f6fd581b			1	1	0	0	1
413			544662ee7668			1	1	0	0	1
414			8eb75dc14132			1	1	0	0	1
415			a3d771e36749			1	1	0	0	1
416			cfad31113843			1	1	0	0	1
417			7f27e2f7b928			1	1	0	0	1
418			c0c1ba22d182			1	1	0	0	1
420			069ebc3471b7			1	1	0	0	1
421			91b7461e02f7			1	1	0	0	1
422			3eab2993fab5			1	1	0	0	1
423			b00ec74ea137			1	1	0	0	1
424			df7f2f79a88b			1	1	0	0	1
425			066c9a9e44a4			1	1	0	0	1
426			515b463adc46			1	1	0	0	1
427			4666015fdf58			1	1	0	0	1
428			42fa2f6e2729			1	1	0	0	1
429			34a35d92efdf			1	1	0	0	1
430			9e29a5a10537			1	1	0	0	1
431			7cffe884153a			1	1	0	0	1
432			9f425e186e30			1	1	0	0	1
433			185831d2a0c6			1	1	0	0	1
434			0c5ac4770696			1	1	0	0	1
435			490b5024a8c1			1	1	0	0	1
436			19222181bfbd			1	1	0	0	1
437			623dcdf9b55e			1	1	0	0	1
438			584127aa15a0			1	1	0	0	1
439			0320936129e8			1	1	0	0	1
441			a85a4b8d6d17			1	1	0	0	1
442			00734046e0a7			1	1	0	0	1
443			714584f58d42			1	1	0	0	1
444			4184aabcb96f			1	1	0	0	1
445			6afdada5c261			1	1	0	0	1
446			ef3f185faff6			1	1	0	0	1
447			beed083490f6			1	1	0	0	1
448			c54a6807f1e4			1	1	0	0	1
449			49add84cd16f			1	1	0	0	1
450			549c83dfca78			1	1	0	0	1
451			d9fd755eb011			1	1	0	0	1
452			8780be6e66b1			1	1	0	0	1
453			8e6b6cca7c69			1	1	0	0	1
454			58777564832a			1	1	0	0	1
455			927e178b5e85			1	1	0	0	1
456			d8fac1a42697			1	1	0	0	1
457			c4d28e4e56c9			1	1	0	0	1
458			197c5d83bd89			1	1	0	0	1
459			e2d0475f7153			1	1	0	0	1
460			5a01366d668d			1	1	0	0	1
462			c3bae4da3d3a			1	1	0	0	1
463			6869a53992a8			1	1	0	0	1
464			9f1035fc0f46			1	1	0	0	1
465			21b33bdc6c3b			1	1	0	0	1
466			54f15d337a77			1	1	0	0	1
467			51bbefb9c736			1	1	0	0	1
468			5a0e2b76f966			1	1	0	0	1
469			d5345b3862f7			1	1	0	0	1
470			5c66f2fba2b2			1	1	0	0	1
471			ec0438b5da95			1	1	0	0	1
472			9bb7592bc181			1	1	0	0	1
473			2bd41d75289a			1	1	0	0	1
474			55331f7bf1df			1	1	0	0	1
475			f2060b1fd7b7			1	1	0	0	1
476			50455bda7cb2			1	1	0	0	1
477			e510233237e4			1	1	0	0	1
478			935eb8518ff4			1	1	0	0	1
479			35af28512388			1	1	0	0	1
480			987ca5d81b42			1	1	0	0	1
481			2da2e0e31e79			1	1	0	0	1
483			801690565bab			1	1	0	0	1
484			71394512d5b9			1	1	0	0	1
485			9184be0d2326			1	1	0	0	1
486			0dab5d410bec			1	1	0	0	1
487			4f2fca266980			1	1	0	0	1
488			3379b42db34e			1	1	0	0	1
490			1617ca5e0e78			1	1	0	0	1
491			3a88560b662f			1	1	0	0	1
492			5c3da88ad14c			1	1	0	0	1
493			a71ecf0dc66c			1	1	0	0	1
494			286d4e924e01			1	1	0	0	1
496			1c2e5903182b			1	1	0	0	1
497			4821e5c556ec			1	1	0	0	1
498			d6f790c0580d			1	1	0	0	1
499			33792eb7d134			1	1	0	0	1
500			6bee9a44da6c			1	1	0	0	1
501			946925eebe69			1	1	0	0	1
502			4962c4454ebd			1	1	0	0	1
503			ec9cec1b4ead			1	1	0	0	1
504			a3ba545bbb98			1	1	0	0	1
505			b5289ec3fa85			1	1	0	0	1
506			8a62da8255c2			1	1	0	0	1
507			f003fa2d6e38			1	1	0	0	1
508			b1d2caad8e22			1	1	0	0	1
509			a7eefd3af2a3			1	1	0	0	1
510			65c7f9420146			1	1	0	0	1
511			6092f558c4a9			1	1	0	0	1
512			d1e7e99a59e9			1	1	0	0	1
513			8a65e2ce6223			1	1	0	0	1
514			a713ff1ebc9f			1	1	0	0	1
515			fbc0b20066d8			1	1	0	0	1
517			409e74913676			1	1	0	0	1
518			8c144f1053f5			1	1	0	0	1
519			af0b4378c7e4			1	1	0	0	1
520			2cf5bdbf708f			1	1	0	0	1
521			4b510bca6b8d			1	1	0	0	1
522			8d40fac215f4			1	1	0	0	1
523			4ce9265ed549			1	1	0	0	1
524			bf999240edfb			1	1	0	0	1
525			4bac8dc8212f			1	1	0	0	1
526			0591fe742aff			1	1	0	0	1
527			4d6bd6e4f475			1	1	0	0	1
528			7fd920da29c7			1	1	0	0	1
529			d1860b837ac2			1	1	0	0	1
530			8442a968dcd8			1	1	0	0	1
531			b1a893edbb6a			1	1	0	0	1
532			d4d15228c06f			1	1	0	0	1
533			a5ef31a27220			1	1	0	0	1
534			24a32abcbff3			1	1	0	0	1
535			cb4fb4096175			1	1	0	0	1
536			4b8262f1d3e3			1	1	0	0	1
538			882d795be8cf			1	1	0	0	1
539			c7e54ab529ca			1	1	0	0	1
540			6b48c4142e98			1	1	0	0	1
541			d5411010f7a2			1	1	0	0	1
542			baedcf5bd8b7			1	1	0	0	1
543			d229af8d0389			1	1	0	0	1
544			1d0c98636f4b			1	1	0	0	1
545			55b66dfdb7cd			1	1	0	0	1
546			8ba6b096ba64			1	1	0	0	1
547			dde943c1a675			1	1	0	0	1
548			71b43c2179e4			1	1	0	0	1
549			17ace841eaaf			1	1	0	0	1
550			cc2678b13761			1	1	0	0	1
551			a5ed525c7779			1	1	0	0	1
552			42a022a92045			1	1	0	0	1
553			282f6875ac52			1	1	0	0	1
554			b440033d1b2f			1	1	0	0	1
555			56ceb7e4fcc3			1	1	0	0	1
556			c1b4ae043cb0			1	1	0	0	1
557			94ea5a340dd2			1	1	0	0	1
559			91d86c299de7			1	1	0	0	1
560			3f2934808ad5			1	1	0	0	1
561			56fa529f509f			1	1	0	0	1
562			7ff8038a4312			1	1	0	0	1
563			276205c451e8			1	1	0	0	1
564			4bbba56166f1			1	1	0	0	1
565			8efad2358fa8			1	1	0	0	1
566			2c8272432e46			1	1	0	0	1
567			dafb7ee094a7			1	1	0	0	1
568			96110b07abeb			1	1	0	0	1
569			c84b540473ac			1	1	0	0	1
570			650332710b68			1	1	0	0	1
571			7be65806b969			1	1	0	0	1
572			78a45518a455			1	1	0	0	1
573			2bea462a10be			1	1	0	0	1
574			f4ef3b78a3d4			1	1	0	0	1
575			e211f752be82			1	1	0	0	1
576			1d98a4309c11			1	1	0	0	1
577			3af0460785ac			1	1	0	0	1
578			897b3f3a390c			1	1	0	0	1
580			9679d6da536b			1	1	0	0	1
581			de96188a83fe			1	1	0	0	1
582			ea15c93dfbfa			1	1	0	0	1
583			486faa6f1130			1	1	0	0	1
584			54cdd2c99934			1	1	0	0	1
585			6cff90e0a8b7			1	1	0	0	1
587			eb9f88d3c1cd			1	1	0	0	1
588			cabe4047881e			1	1	0	0	1
589			585ddaab6952			1	1	0	0	1
590			951e39bc8c5c			1	1	0	0	1
591			89dd7dad2f83			1	1	0	0	1
593			880432ba8242			1	1	0	0	1
594			dc4f0e738a25			1	1	0	0	1
595			47d71f3bbf6c			1	1	0	0	1
596			5baec028a725			1	1	0	0	1
597			f7f6b69fbb64			1	1	0	0	1
598			3153abfce595			1	1	0	0	1
599			8333afe01cab			1	1	0	0	1
600			55f9ddec54d6			1	1	0	0	1
601			55b01570f365			1	1	0	0	1
602			a8d425925441			1	1	0	0	1
603			078754cceba5			1	1	0	0	1
604			a9db5c1be42a			1	1	0	0	1
605			e270d204af65			1	1	0	0	1
606			f2c1e1e2825f			1	1	0	0	1
607			23b17ee3df0d			1	1	0	0	1
608			443098c629a2			1	1	0	0	1
609			df30eb8728e4			1	1	0	0	1
610			8bb2066366d2			1	1	0	0	1
611			f884d6fbce65			1	1	0	0	1
612			67528848ede2			1	1	0	0	1
614			878813bff733			1	1	0	0	1
615			c4031ce8c581			1	1	0	0	1
616			c77b4166c993			1	1	0	0	1
617			ba50405a2e05			1	1	0	0	1
618			1a9db698cd35			1	1	0	0	1
619			10c2b3bc4fee			1	1	0	0	1
620			5f9827422874			1	1	0	0	1
621			f0901ba4f929			1	1	0	0	1
622			9c807cbd9507			1	1	0	0	1
623			08e293e32b72			1	1	0	0	1
624			60fbe7de2e8c			1	1	0	0	1
625			edbf5cae020e			1	1	0	0	1
626			aaa366f9bcba			1	1	0	0	1
627			8a089c655eb5			1	1	0	0	1
628			12621543e4e5			1	1	0	0	1
629			c4ff954882ce			1	1	0	0	1
630			5a4a2247ab24			1	1	0	0	1
631			4955dae1ebea			1	1	0	0	1
632			2bf2080f266a			1	1	0	0	1
633			f47a0c69cb9a			1	1	0	0	1
635			ef7ad90ac001			1	1	0	0	1
636			8596d98b45ad			1	1	0	0	1
637			b8d982daf9a2			1	1	0	0	1
638			cdcf713c7bc0			1	1	0	0	1
639			8e231b6a726f			1	1	0	0	1
640			650942c7854c			1	1	0	0	1
641			cafa820ae2e9			1	1	0	0	1
642			343bc253d1f4			1	1	0	0	1
643			8dcc2ec6c03f			1	1	0	0	1
644			05f3cf5d764d			1	1	0	0	1
645			752d4cb7b4e1			1	1	0	0	1
646			5ab014a34aff			1	1	0	0	1
647			69fc3fc5f883			1	1	0	0	1
648			a9e1e98bd7f5			1	1	0	0	1
649			1e4e84a5ad9f			1	1	0	0	1
650			3c8142d7c9fa			1	1	0	0	1
651			6ff326030a79			1	1	0	0	1
652			36f990a274d2			1	1	0	0	1
653			4850576dcacc			1	1	0	0	1
654			65d921d7b850			1	1	0	0	1
656			e2db177539b8			1	1	0	0	1
657			8b6f3217c68b			1	1	0	0	1
658			d417908b7470			1	1	0	0	1
659			428b9ee6150e			1	1	0	0	1
660			400a28c225ef			1	1	0	0	1
661			19be72d9169f			1	1	0	0	1
662			c74a6fecf571			1	1	0	0	1
663			e8b41a4a0f11			1	1	0	0	1
664			c6a9e545511a			1	1	0	0	1
665			0936925e4b80			1	1	0	0	1
666			5ccb382de005			1	1	0	0	1
667			4c13009c2532			1	1	0	0	1
668			f2609f22e8c5			1	1	0	0	1
669			5c59ff8d042b			1	1	0	0	1
670			a83da3a27b1e			1	1	0	0	1
671			b65f9aae6ab8			1	1	0	0	1
672			e822c4ecc662			1	1	0	0	1
673			91d6a99e50c3			1	1	0	0	1
674			0167dafd7b86			1	1	0	0	1
675			53631cf5ab56			1	1	0	0	1
677			91aaf2f2241b			1	1	0	0	1
678			694bcb150284			1	1	0	0	1
679			edc6d5435fa9			1	1	0	0	1
680			22afb68545a0			1	1	0	0	1
681			53e41b0e1e47			1	1	0	0	1
682			19fa9b73c5ae			1	1	0	0	1
684			bbe25a8555d6			1	1	0	0	1
685			112dccc0e7a9			1	1	0	0	1
686			db200b40e83b			1	1	0	0	1
687			e6829e1705cb			1	1	0	0	1
688			9365c5bfa5ef			1	1	0	0	1
690			ef9fe2218078			1	1	0	0	1
691			c375e746547d			1	1	0	0	1
692			4ab0277f759f			1	1	0	0	1
693			b5ca73a70c61			1	1	0	0	1
694			1af13333ddb0			1	1	0	0	1
695			292e480b78d8			1	1	0	0	1
696			f5a874ce5bd6			1	1	0	0	1
697			226fca51dc5d			1	1	0	0	1
698			e938698d4b12			1	1	0	0	1
699			73c30c00e5fa			1	1	0	0	1
700			5f7877f0615f			1	1	0	0	1
701			197022c67272			1	1	0	0	1
702			102c80a1bf31			1	1	0	0	1
703			3f6cf5d4741f			1	1	0	0	1
704			d702c69542e1			1	1	0	0	1
705			b12cae238b78			1	1	0	0	1
706			4906de2cac78			1	1	0	0	1
707			3b3f494d4930			1	1	0	0	1
708			26eac28703ca			1	1	0	0	1
709			d5da7f2a4628			1	1	0	0	1
711			b9515cac0bef			1	1	0	0	1
712			db65ee7d7db7			1	1	0	0	1
713			fa01ca32dc66			1	1	0	0	1
714			2dcc79e41f45			1	1	0	0	1
715			b6f55ea028a0			1	1	0	0	1
716			6aa0a5345695			1	1	0	0	1
717			ffbf30ad84aa			1	1	0	0	1
718			b446d1b8b6d6			1	1	0	0	1
719			02b13769434c			1	1	0	0	1
720			7e8bd3adc94d			1	1	0	0	1
721			3b67a771a184			1	1	0	0	1
722			d0c8c6860983			1	1	0	0	1
723			f79e035b0b5e			1	1	0	0	1
724			fec9f0917724			1	1	0	0	1
725			cd2c4231e328			1	1	0	0	1
726			ab5228dacec6			1	1	0	0	1
727			c47dd7ee4d2a			1	1	0	0	1
728			c1e563ab1c84			1	1	0	0	1
729			e94733324e54			1	1	0	0	1
730			f5c42312cc75			1	1	0	0	1
732			503983c2deb7			1	1	0	0	1
733			f63c4780bad0			1	1	0	0	1
734			1d9539b39fca			1	1	0	0	1
735			8a9eda55d85e			1	1	0	0	1
736			25545486b147			1	1	0	0	1
737			1aa661c2d176			1	1	0	0	1
738			1cf69a743589			1	1	0	0	1
739			3c6edafe81c0			1	1	0	0	1
740			d8437f686a25			1	1	0	0	1
741			e875f6d18848			1	1	0	0	1
742			8423aed5b4fb			1	1	0	0	1
743			80820c7946ae			1	1	0	0	1
744			9980295cd50a			1	1	0	0	1
745			6cd89071c0e8			1	1	0	0	1
746			bc061b97fbed			1	1	0	0	1
747			ca5670e57976			1	1	0	0	1
748			a16c90b61232			1	1	0	0	1
749			00dc22853406			1	1	0	0	1
750			02777953a2c2			1	1	0	0	1
751			0e773dce21e1			1	1	0	0	1
753			cc8abb535190			1	1	0	0	1
754			ff363f2a90ad			1	1	0	0	1
755			0039d424aff2			1	1	0	0	1
756			87f0993cb73c			1	1	0	0	1
757			e3ab934a8937			1	1	0	0	1
758			0dff6ccabbe3			1	1	0	0	1
759			9995fd018325			1	1	0	0	1
760			05e140456dce			1	1	0	0	1
761			90c5fb465651			1	1	0	0	1
762			4f249fb3dfdf			1	1	0	0	1
763			c765563c3173			1	1	0	0	1
764			ebb7add4e40e			1	1	0	0	1
765			207caec6f2f8			1	1	0	0	1
766			50a3a426d9c0			1	1	0	0	1
767			bb2583ea0db7			1	1	0	0	1
768			7b27e37464be			1	1	0	0	1
769			a2c2d780c49f			1	1	0	0	1
770			9cfcac25b76f			1	1	0	0	1
771			1f829174ffeb			1	1	0	0	1
772			11c1aadf02f5			1	1	0	0	1
774			27c2109c637e			1	1	0	0	1
775			6de8bfc9d4a0			1	1	0	0	1
776			ebfd7e6312a0			1	1	0	0	1
777			e6f9b42f9ee4			1	1	0	0	1
778			5a85f4679951			1	1	0	0	1
779			77d1ab0c5d56			1	1	0	0	1
781			540f6714740a			1	1	0	0	1
782			3579d4c4bd2f			1	1	0	0	1
783			b279d2246ae8			1	1	0	0	1
784			e11727f81dd6			1	1	0	0	1
785			2012cd3fcdef			1	1	0	0	1
787			b631320e6797			1	1	0	0	1
788			07bec58c460e			1	1	0	0	1
789			9685daed5bfc			1	1	0	0	1
790			ec9446785512			1	1	0	0	1
791			7578d543916d			1	1	0	0	1
792			a3e39571f137			1	1	0	0	1
793			3b31b335edaf			1	1	0	0	1
794			fcea02eb154a			1	1	0	0	1
795			df62bca26d56			1	1	0	0	1
796			8f20172301b1			1	1	0	0	1
797			529afaa10132			1	1	0	0	1
798			adcb7fe21180			1	1	0	0	1
799			4ca43b7c2bf5			1	1	0	0	1
800			d6b3a94a3a4d			1	1	0	0	1
801			92d3097a7272			1	1	0	0	1
802			b6b7985f4eed			1	1	0	0	1
803			76246d0c6067			1	1	0	0	1
804			9d50e2d55700			1	1	0	0	1
805			c913e5b0ad52			1	1	0	0	1
806			3f86966f17f6			1	1	0	0	1
808			d9ce80f0902f			1	1	0	0	1
809			6d9467fd9f98			1	1	0	0	1
810			db0571dc134a			1	1	0	0	1
811			b4796f7a670f			1	1	0	0	1
812			9b14eceb7bb7			1	1	0	0	1
813			606e391b252d			1	1	0	0	1
814			002a58397059			1	1	0	0	1
815			948916e19790			1	1	0	0	1
816			ed83fb793a11			1	1	0	0	1
817			2116295edf2d			1	1	0	0	1
818			e878c95299ff			1	1	0	0	1
819			5b74e39ba6be			1	1	0	0	1
820			f3754e87097c			1	1	0	0	1
821			21d4af77993f			1	1	0	0	1
822			b21b9ab46f27			1	1	0	0	1
823			317380feaef9			1	1	0	0	1
824			699dc6237430			1	1	0	0	1
825			cae3065b06cc			1	1	0	0	1
826			d5507799ccb6			1	1	0	0	1
827			c48f2f49840e			1	1	0	0	1
829			1b44a9fb9aba			1	1	0	0	1
830			91b8274b0d11			1	1	0	0	1
831			ebfd93cd3af0			1	1	0	0	1
832			dfe983897a39			1	1	0	0	1
833			ea4924d3269d			1	1	0	0	1
834			2fa675628ae9			1	1	0	0	1
835			1defe4af6551			1	1	0	0	1
836			95c55a20f931			1	1	0	0	1
837			f6d6b8db5629			1	1	0	0	1
838			50aec5e987da			1	1	0	0	1
839			3b0bb5558fa4			1	1	0	0	1
840			71d16fb90263			1	1	0	0	1
841			ccbbe7e987bf			1	1	0	0	1
842			3647df7ec112			1	1	0	0	1
843			03734406a55e			1	1	0	0	1
844			5efba1126b60			1	1	0	0	1
845			9a7092a1c228			1	1	0	0	1
846			31fce5295381			1	1	0	0	1
847			e97b96033811			1	1	0	0	1
848			3e332c1bb3e2			1	1	0	0	1
850			94d7d59ff94d			1	1	0	0	1
851			9315ce01e885			1	1	0	0	1
852			1434f6dc37d4			1	1	0	0	1
853			b884bd894345			1	1	0	0	1
854			209e0771fe12			1	1	0	0	1
855			d47120b5ee85			1	1	0	0	1
856			0e2f8d091ae1			1	1	0	0	1
857			ef3afaaf1824			1	1	0	0	1
858			96ae93e9d733			1	1	0	0	1
859			d9c054131f4f			1	1	0	0	1
860			ff420b880dff			1	1	0	0	1
861			90526ded9cba			1	1	0	0	1
862			0ceb5b5dbe9e			1	1	0	0	1
863			fc0c4d2343ee			1	1	0	0	1
864			b14e935a3087			1	1	0	0	1
865			99c18c7b1c7a			1	1	0	0	1
866			164e45a2160f			1	1	0	0	1
867			4f6d13ba7a15			1	1	0	0	1
868			da6f61b5d2bb			1	1	0	0	1
869			793f3e8d8614			1	1	0	0	1
871			6e982a127b53			1	1	0	0	1
872			bea04cac4e5c			1	1	0	0	1
873			bfa4fcb5f7a2			1	1	0	0	1
874			3940f467bad7			1	1	0	0	1
875			23b8783fe4f9			1	1	0	0	1
876			095eb6544c6c			1	1	0	0	1
878			a85dd95d7f01			1	1	0	0	1
879			f34c936c863b			1	1	0	0	1
880			edfb382b1408			1	1	0	0	1
881			92e713bcee21			1	1	0	0	1
882			8dab40ae8833			1	1	0	0	1
884			43e156b049ec			1	1	0	0	1
885			81e95fb8983c			1	1	0	0	1
886			d57ad4e6ce72			1	1	0	0	1
887			d3026e3544a3			1	1	0	0	1
888			48bbebf4261a			1	1	0	0	1
889			3877ba3e599e			1	1	0	0	1
890			206641fa60d5			2	1	0	0	1
891			15591b02f51c			2	1	0	0	1
892			dc4b1f81abc0			2	1	0	0	1
893			383b5a3006d5			2	1	0	0	1
894			011bf4d86c28			2	1	0	0	1
895			b7d442c9aee7			2	1	0	0	1
896			a43a23bad93b			2	1	0	0	1
897			469fb40e8429			2	1	0	0	1
898			7e9c77879f3b			2	1	0	0	1
899			26c69dcb7607			2	1	0	0	1
900			1ed54286eff5			2	1	0	0	1
901			cd341d8d4df7			2	1	0	0	1
902			cd7db84ab291			2	1	0	0	1
903			aa3607907a85			2	1	0	0	1
905			72f277f46de0			2	1	0	0	1
906			f2977bc7ff67			2	1	0	0	1
907			87fb86bcbba8			2	1	0	0	1
908			f002809588ff			2	1	0	0	1
909			e14897fbb39d			2	1	0	0	1
910			b0032a345036			2	1	0	0	1
911			0f729f6b9391			2	1	0	0	1
912			0c92af647428			2	1	0	0	1
913			2721f76cac7d			2	1	0	0	1
914			311849868ea7			2	1	0	0	1
915			b67b817bd3b3			2	1	0	0	1
916			17bdd36872be			2	1	0	0	1
917			46b4f987d257			2	1	0	0	1
918			19db6f2d8e1e			2	1	0	0	1
919			777fa6396d2a			2	1	0	0	1
920			bbbec6875574			2	1	0	0	1
921			3333c23a1cd3			2	1	0	0	1
922			1ef91911a3b7			2	1	0	0	1
923			96384b22e087			2	1	0	0	1
924			ace7993f46b1			2	1	0	0	1
926			67f5d5245c04			2	1	0	0	1
927			1c40c468a9a4			2	1	0	0	1
928			a63e8cf13d29			2	1	0	0	1
929			3c9970fe150c			2	1	0	0	1
930			dcec9cdc3bb0			2	1	0	0	1
931			bb940d7b15e6			2	1	0	0	1
932			95167d91e9b5			2	1	0	0	1
933			1447a0e954d6			2	1	0	0	1
934			ba452ef77aba			2	1	0	0	1
935			cc98d66c06e3			2	1	0	0	1
936			335619571b25			2	1	0	0	1
937			7c199d15de97			2	1	0	0	1
938			0e627e9b23ba			2	1	0	0	1
939			75f67b81295a			2	1	0	0	1
940			d6003f7945fe			2	1	0	0	1
941			31b2863616ca			2	1	0	0	1
942			b26b96b24e14			2	1	0	0	1
943			c57f038016fe			2	1	0	0	1
944			e406e57fe5ca			2	1	0	0	1
945			b97b23c8a71b			2	1	0	0	1
947			66303b84f080			2	1	0	0	1
948			7bd8b01f3fb7			2	1	0	0	1
949			b7be93b4cbe4			2	1	0	0	1
950			6328cce72701			2	1	0	0	1
951			c2be4983b6f5			2	1	0	0	1
952			0715e522cdee			2	1	0	0	1
953			7b85c3802f1f			2	1	0	0	1
954			f41e99b0b58c			2	1	0	0	1
955			808c3b613141			2	1	0	0	1
956			aa0a6b522c78			2	1	0	0	1
957			d7f4ba0cc567			2	1	0	0	1
958			2f7f48bf7c18			2	1	0	0	1
959			54c242d75fd4			2	1	0	0	1
960			4ef36c9f7b7f			2	1	0	0	1
961			f2ddd41daef8			2	1	0	0	1
962			77eb68555403			2	1	0	0	1
963			da4319d1677d			2	1	0	0	1
964			8953e6894406			2	1	0	0	1
965			edf92f10072b			2	1	0	0	1
966			729e5e01ebeb			2	1	0	0	1
968			5caab55b1fa3			2	1	0	0	1
969			20db9cac39ab			2	1	0	0	1
970			001b2de4a211			2	1	0	0	1
988			7fbc4b606807			2	1	0	0	1
989			ed2ce9fa85bc			2	1	0	0	1
990			c8b613d3dd08			2	1	0	0	1
1034			bd07fc9f4413			3	1	0	0	1
1035			1184d5c759cf			3	1	0	0	1
992			9f41718c05e1			2	1	0	0	1
993			1065a23e4f36			2	1	0	0	1
994			38f579e16cc3			2	1	0	0	1
995			fc072dd7a483			2	1	0	0	1
996			d30b11525cf7			2	1	0	0	1
998			04bfd5fc6655			2	1	0	0	1
999			9a07c88a0be7			2	1	0	0	1
1000			12c429f79112			2	1	0	0	1
1001			e8e063462b30			2	1	0	0	1
1002			fbb94c1ad05d			2	1	0	0	1
1003			c1e479064493			2	1	0	0	1
1004			49a9099f6f77			2	1	0	0	1
1005			0688db583072			2	1	0	0	1
1006			90a912ee55a1			2	1	0	0	1
1007			474d58a0a3d5			2	1	0	0	1
1008			9a337a436cea			2	1	0	0	1
1009			c883a234833d			3	1	0	0	1
1010			998c09eda437			3	1	0	0	1
1011			bba7798fc5c3			3	1	0	0	1
1012			93877e922fed			3	1	0	0	1
1013			9c2f68fcf352			3	1	0	0	1
1014			7d3ed7c7d3be			3	1	0	0	1
1015			f5fea0f656cd			3	1	0	0	1
1016			f7be00f0aafd			3	1	0	0	1
1017			076c938b2f30			3	1	0	0	1
1019			f8b2521b5e93			3	1	0	0	1
1020			6d5b39b9c724			3	1	0	0	1
1021			95185d7c61ac			3	1	0	0	1
1022			ba08cd473e2a			3	1	0	0	1
1023			67e9c17a6f3d			3	1	0	0	1
1024			0849df7a4d79			3	1	0	0	1
1025			37ebfc0e42eb			3	1	0	0	1
1026			2880e8a9b23c			3	1	0	0	1
1027			50478dffb830			3	1	0	0	1
1028			719de8e6eb91			3	1	0	0	1
1029			04dc2cdd3732			3	1	0	0	1
1030			13bcf50b1551			3	1	0	0	1
1032			lagroup			5	1	0	0	1
1090			ce38d8488dcc			2	1	0	0	1
1187			ba63e25af6d5			1	1	0	0	1
1284			ef011856e1d4			1	1	0	0	1
1381			8f95652598b9			1	1	0	0	1
1033			d25138ae259b			4	1	0	0	1
4			9a0fcdab37ab			1	1	0	0	1
10			c56433416e79			1	1	0	0	1
31			3f4935da2b3a			1	1	0	0	1
52			59a734d1e508			1	1	0	0	1
73			9b57fc877b91			1	1	0	0	1
94			f81f45fec5b9			1	1	0	0	1
101			bb9d8efd255f			1	1	0	0	1
107			27fa87bfbd41			1	1	0	0	1
128			7ce0e20476c1			1	1	0	0	1
149			5357b1412e18			1	1	0	0	1
170			df217b717b46			1	1	0	0	1
191			608dede36a09			1	1	0	0	1
198			37cb6aeb714e			1	1	0	0	1
204			99ba623f2016			1	1	0	0	1
225			8f44967f2f81			1	1	0	0	1
246			c9b6c0f5211e			1	1	0	0	1
267			713094fd57dc			1	1	0	0	1
288			8bd264e32701			1	1	0	0	1
295			ab86c3066a46			1	1	0	0	1
301			2c13d348d035			1	1	0	0	1
322			fb6fa5b1c0f5			1	1	0	0	1
343			d80927d881ff			1	1	0	0	1
364			139a64da0681			1	1	0	0	1
385			7fc492661336			1	1	0	0	1
392			b59375c9d2a2			1	1	0	0	1
398			8ebd88a68416			1	1	0	0	1
419			e4b61e048bab			1	1	0	0	1
440			2463e0a5275c			1	1	0	0	1
461			a0e93be3c3aa			1	1	0	0	1
482			84ee90c315ce			1	1	0	0	1
489			9d3701fe4796			1	1	0	0	1
495			5119e2ccd272			1	1	0	0	1
516			9cdf883d9649			1	1	0	0	1
537			5ef881eb521b			1	1	0	0	1
558			33c282a27659			1	1	0	0	1
579			c5b756acee62			1	1	0	0	1
586			35f74398f7ad			1	1	0	0	1
592			6f93b6781a62			1	1	0	0	1
613			e012f03602df			1	1	0	0	1
634			8f3f6bb6a193			1	1	0	0	1
655			e8a1cfd99734			1	1	0	0	1
676			61fb90004626			1	1	0	0	1
683			74fe68ac243e			1	1	0	0	1
689			b9739898cb0d			1	1	0	0	1
710			b44878fe8520			1	1	0	0	1
731			8f6ab46e8b2c			1	1	0	0	1
752			26e4f8824481			1	1	0	0	1
773			722ac3c73849			1	1	0	0	1
780			ceaec24723b5			1	1	0	0	1
786			318ec683891b			1	1	0	0	1
807			41abacc22dd7			1	1	0	0	1
828			da3276a218a9			1	1	0	0	1
849			fb1af48ae009			1	1	0	0	1
870			09457e7ae8d3			1	1	0	0	1
877			c4f773ae5632			1	1	0	0	1
883			1af9b2b2a1f0			1	1	0	0	1
904			46fde4e418cd			2	1	0	0	1
925			b941ca5f846a			2	1	0	0	1
946			f42e5fe902b6			2	1	0	0	1
967			b03bc5a65abb			2	1	0	0	1
991			d3a8c1fd90f5			2	1	0	0	1
997			3b5ebe750836			2	1	0	0	1
1018			137090eb85b6			3	1	0	0	1
1353			ec0b1be26c9f			1	1	0	0	1
1357			2a1bf8e50061			1	1	0	0	1
1360			e57cc66be427			1	1	0	0	1
1364			088bf8ff430c			1	1	0	0	1
1368			34f0c27e574b			1	1	0	0	1
1372			6ae526952c36			1	1	0	0	1
1376			aacf9c0e9626			1	1	0	0	1
1379			2b950fabc419			1	1	0	0	1
1380			b8ac47996d44			1	1	0	0	1
1384			9c617546dc2e			1	1	0	0	1
1388			1eecbc9bbd45			1	1	0	0	1
1392			94327e31dd65			1	1	0	0	1
1396			21492c68c7d9			1	1	0	0	1
1400			094cc71e1250			1	1	0	0	1
1403			6dce26a393cd			1	1	0	0	1
1407			e3df803c2f33			1	1	0	0	1
1411			192c4fb5e3ae			1	1	0	0	1
1415			b2ecfc0c3c50			1	1	0	0	1
1419			97eafc069175			1	1	0	0	1
1423			3f1b8548fe13			1	1	0	0	1
1427			a81c93669aee			1	1	0	0	1
1430			4368d3d703dc			1	1	0	0	1
1434			588b93a01c3f			1	1	0	0	1
1438			f1da8a9181e6			1	1	0	0	1
1442			05ae4de2139f			1	1	0	0	1
1446			0c9e143fd6cb			1	1	0	0	1
1450			2bebf52b274e			1	1	0	0	1
1454			97939c997b27			1	1	0	0	1
1457			cd2330194db3			1	1	0	0	1
1461			75f56e8c29a5			1	1	0	0	1
1465			9b99ab5c01e9			1	1	0	0	1
1469			a9bc84805aab			1	1	0	0	1
1473			1259a45e42e2			1	1	0	0	1
1476			885725e2fbbc			1	1	0	0	1
1480			a31e994ca3bb			1	1	0	0	1
1484			1800101478c2			1	1	0	0	1
1488			57013e00f8fd			1	1	0	0	1
1491			b3dd5dca4a38			1	1	0	0	1
1031	Gabriele	Venturini	twisted	team03	area03	2	4	0	0	2
\.


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cocacola
--

SELECT pg_catalog.setval('user_id_seq', 132, true);


--
-- Name: area area_pkey; Type: CONSTRAINT; Schema: public; Owner: cocacola
--

ALTER TABLE ONLY area
    ADD CONSTRAINT area_pkey PRIMARY KEY (id);


--
-- Name: game_action game_action_pkey; Type: CONSTRAINT; Schema: public; Owner: cocacola
--

ALTER TABLE ONLY game_action
    ADD CONSTRAINT game_action_pkey PRIMARY KEY (id);


--
-- Name: game_session game_session_pkey; Type: CONSTRAINT; Schema: public; Owner: cocacola
--

ALTER TABLE ONLY game_session
    ADD CONSTRAINT game_session_pkey PRIMARY KEY (id);


--
-- Name: point_multiplier point_multiplier_pkey; Type: CONSTRAINT; Schema: public; Owner: cocacola
--

ALTER TABLE ONLY point_multiplier
    ADD CONSTRAINT point_multiplier_pkey PRIMARY KEY (id);


--
-- Name: team team_pkey; Type: CONSTRAINT; Schema: public; Owner: cocacola
--

ALTER TABLE ONLY team
    ADD CONSTRAINT team_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: cocacola
--

ALTER TABLE ONLY "user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: area_code_uindex; Type: INDEX; Schema: public; Owner: cocacola
--

CREATE UNIQUE INDEX area_code_uindex ON area USING btree (code);


--
-- Name: game_action_game_id_item_id_user_id_uindex; Type: INDEX; Schema: public; Owner: cocacola
--

CREATE UNIQUE INDEX game_action_game_id_item_id_user_id_uindex ON game_action USING btree (game_id, item_id, user_id);


--
-- Name: point_multiplier_team_code_special_game_id_uindex; Type: INDEX; Schema: public; Owner: cocacola
--

CREATE UNIQUE INDEX point_multiplier_team_code_special_game_id_uindex ON point_multiplier USING btree (team_code, special_game_id);


--
-- Name: team_code_area_code_uindex; Type: INDEX; Schema: public; Owner: cocacola
--

CREATE UNIQUE INDEX team_code_area_code_uindex ON team USING btree (code, area_code);


--
-- Name: user_app_code_uindex; Type: INDEX; Schema: public; Owner: cocacola
--

CREATE UNIQUE INDEX user_app_code_uindex ON "user" USING btree (app_code);


--
-- Name: point_multiplier tr_multipliers; Type: TRIGGER; Schema: public; Owner: cocacola
--

CREATE TRIGGER tr_multipliers AFTER INSERT OR DELETE OR UPDATE ON point_multiplier FOR EACH ROW EXECUTE PROCEDURE fn_multiply_points();


--
-- Name: game_action tr_points; Type: TRIGGER; Schema: public; Owner: cocacola
--

CREATE TRIGGER tr_points AFTER INSERT OR DELETE OR UPDATE ON game_action FOR EACH ROW EXECUTE PROCEDURE fn_update_points();


--
-- Name: game_session tr_seconds; Type: TRIGGER; Schema: public; Owner: cocacola
--

CREATE TRIGGER tr_seconds AFTER INSERT OR DELETE OR UPDATE ON game_session FOR EACH ROW EXECUTE PROCEDURE fn_update_seconds();


--
-- Name: user tr_user_area; Type: TRIGGER; Schema: public; Owner: cocacola
--

CREATE TRIGGER tr_user_area AFTER INSERT OR UPDATE ON "user" FOR EACH ROW EXECUTE PROCEDURE fn_create_area();


--
-- Name: user tr_user_team; Type: TRIGGER; Schema: public; Owner: cocacola
--

CREATE TRIGGER tr_user_team AFTER INSERT OR UPDATE ON "user" FOR EACH ROW EXECUTE PROCEDURE fn_create_team();


--
-- Name: game_action game_action_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: cocacola
--

ALTER TABLE ONLY game_action
    ADD CONSTRAINT game_action_user_id_fk FOREIGN KEY (user_id) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: game_session game_session_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: cocacola
--

ALTER TABLE ONLY game_session
    ADD CONSTRAINT game_session_user_id_fk FOREIGN KEY (user_id) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: point_multiplier point_multiplier_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: cocacola
--

ALTER TABLE ONLY point_multiplier
    ADD CONSTRAINT point_multiplier_user_id_fk FOREIGN KEY (user_id) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

