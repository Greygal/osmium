--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: osmium; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA osmium;


SET search_path = osmium, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accountcharacters; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE accountcharacters (
    accountid integer NOT NULL,
    name character varying(255) NOT NULL,
    keyid integer,
    verificationcode character varying(255),
    importname name,
    importedskillset text,
    overriddenskillset text,
    lastimportdate integer
);


--
-- Name: accountfavorites; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE accountfavorites (
    accountid integer NOT NULL,
    loadoutid integer NOT NULL,
    favoritedate integer NOT NULL
);


--
-- Name: accounts; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    accountid integer NOT NULL,
    accountname character varying(255) NOT NULL,
    passwordhash character varying(255) NOT NULL,
    nickname character varying(255) NOT NULL,
    creationdate integer NOT NULL,
    lastlogindate integer NOT NULL,
    keyid integer,
    verificationcode character varying(255),
    apiverified boolean NOT NULL,
    characterid integer,
    charactername character varying(255),
    corporationid integer,
    corporationname character varying(255),
    allianceid integer,
    alliancename character varying(255),
    isfittingmanager boolean NOT NULL,
    ismoderator boolean NOT NULL,
    flagweight integer NOT NULL,
    reputation integer NOT NULL
);


--
-- Name: accounts_accountid_seq; Type: SEQUENCE; Schema: osmium; Owner: -
--

CREATE SEQUENCE accounts_accountid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_accountid_seq; Type: SEQUENCE OWNED BY; Schema: osmium; Owner: -
--

ALTER SEQUENCE accounts_accountid_seq OWNED BY accounts.accountid;


--
-- Name: accountsettings; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE accountsettings (
    accountid integer NOT NULL,
    key character varying(255) NOT NULL,
    value text
);


--
-- Name: loadouts_loadoutid_seq; Type: SEQUENCE; Schema: osmium; Owner: -
--

CREATE SEQUENCE loadouts_loadoutid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: loadouts; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE loadouts (
    loadoutid integer DEFAULT nextval('loadouts_loadoutid_seq'::regclass) NOT NULL,
    accountid integer NOT NULL,
    viewpermission integer NOT NULL,
    editpermission integer NOT NULL,
    visibility integer NOT NULL,
    passwordhash text,
    allowcomments boolean DEFAULT true NOT NULL,
    privatetoken bigint DEFAULT ((random() * ((2)::double precision ^ (63)::double precision)))::bigint NOT NULL
);


--
-- Name: allowedloadoutsanonymous; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW allowedloadoutsanonymous AS
    SELECT loadouts.loadoutid FROM loadouts WHERE ((loadouts.viewpermission = 0) OR (loadouts.viewpermission = 1));


--
-- Name: allowedloadoutsbyaccount; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW allowedloadoutsbyaccount AS
    SELECT accounts.accountid, loadouts.loadoutid FROM ((loadouts JOIN accounts author ON ((author.accountid = loadouts.accountid))) JOIN accounts ON ((((((loadouts.viewpermission = 0) OR (loadouts.viewpermission = 1)) OR ((((loadouts.viewpermission = 2) AND (accounts.apiverified = true)) AND (author.apiverified = true)) AND (accounts.allianceid = author.allianceid))) OR ((((loadouts.viewpermission = 3) AND (accounts.apiverified = true)) AND (author.apiverified = true)) AND (accounts.corporationid = author.corporationid))) OR (accounts.accountid = author.accountid))));


--
-- Name: clients; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE clients (
    clientid integer NOT NULL,
    remoteaddress inet NOT NULL,
    useragent character varying(4095) NOT NULL,
    accept character varying(1023) NOT NULL,
    loggedinaccountid integer
);


--
-- Name: clients_clientid_seq; Type: SEQUENCE; Schema: osmium; Owner: -
--

CREATE SEQUENCE clients_clientid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clients_clientid_seq; Type: SEQUENCE OWNED BY; Schema: osmium; Owner: -
--

ALTER SEQUENCE clients_clientid_seq OWNED BY clients.clientid;


--
-- Name: cookietokens; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE cookietokens (
    token character varying(255) NOT NULL,
    accountid integer NOT NULL,
    clientattributes character varying(255) NOT NULL,
    expirationdate integer NOT NULL
);


--
-- Name: editableloadoutsbyaccount; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW editableloadoutsbyaccount AS
    SELECT accounts.accountid, loadouts.loadoutid FROM ((loadouts JOIN accounts author ON ((author.accountid = loadouts.accountid))) JOIN accounts ON (((((((((loadouts.editpermission = 3) AND (accounts.apiverified = true)) AND (author.apiverified = true)) AND (accounts.allianceid = author.allianceid)) OR ((((loadouts.editpermission = 2) AND (accounts.apiverified = true)) AND (author.apiverified = true)) AND (accounts.corporationid = author.corporationid))) OR (((((loadouts.editpermission = 1) AND (accounts.apiverified = true)) AND (author.apiverified = true)) AND (accounts.corporationid = author.corporationid)) AND (accounts.isfittingmanager = true))) OR (accounts.accountid = author.accountid)) OR (accounts.ismoderator = true))));


--
-- Name: eveaccounts; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE eveaccounts (
    eveaccountid integer NOT NULL,
    creationdate integer NOT NULL
);


--
-- Name: eveaccounts_eveaccountid_seq; Type: SEQUENCE; Schema: osmium; Owner: -
--

CREATE SEQUENCE eveaccounts_eveaccountid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eveaccounts_eveaccountid_seq; Type: SEQUENCE OWNED BY; Schema: osmium; Owner: -
--

ALTER SEQUENCE eveaccounts_eveaccountid_seq OWNED BY eveaccounts.eveaccountid;


--
-- Name: fittingtags; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE fittingtags (
    fittinghash character(40) NOT NULL,
    tagname character varying(127) NOT NULL
);


--
-- Name: fittingaggtags; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW fittingaggtags AS
    SELECT fittingtags.fittinghash, string_agg(DISTINCT (fittingtags.tagname)::text, ' '::text) AS taglist FROM fittingtags GROUP BY fittingtags.fittinghash;


--
-- Name: fittingchargepresets; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE fittingchargepresets (
    fittinghash character(40) NOT NULL,
    presetid integer NOT NULL,
    chargepresetid integer NOT NULL,
    name character varying(255) NOT NULL,
    description text
);


--
-- Name: fittingcharges; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE fittingcharges (
    fittinghash character(40) NOT NULL,
    presetid integer NOT NULL,
    chargepresetid integer NOT NULL,
    slottype character varying(127) NOT NULL,
    index integer NOT NULL,
    typeid integer NOT NULL
);


--
-- Name: fittingdeltas; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE fittingdeltas (
    fittinghash1 character(40) NOT NULL,
    fittinghash2 character(40) NOT NULL,
    delta text NOT NULL
);


--
-- Name: fittingdronepresets; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE fittingdronepresets (
    fittinghash character(40) NOT NULL,
    dronepresetid integer NOT NULL,
    name character varying(255) NOT NULL,
    description text
);


--
-- Name: fittingpresets; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE fittingpresets (
    fittinghash character(40) NOT NULL,
    presetid integer NOT NULL,
    name character varying(255) NOT NULL,
    description text
);


--
-- Name: fittings; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE fittings (
    fittinghash character(40) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    hullid integer NOT NULL,
    creationdate integer NOT NULL
);


--
-- Name: fittingdescriptions; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW fittingdescriptions AS
    SELECT d.fittinghash, string_agg(d.description, ', '::text) AS descriptions FROM (((SELECT fittings.fittinghash, fittings.description FROM fittings UNION SELECT fittingpresets.fittinghash, fittingpresets.description FROM fittingpresets) UNION SELECT fittingchargepresets.fittinghash, fittingchargepresets.description FROM fittingchargepresets) UNION SELECT fittingdronepresets.fittinghash, fittingdronepresets.description FROM fittingdronepresets) d GROUP BY d.fittinghash;


--
-- Name: fittingdrones; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE fittingdrones (
    fittinghash character(40) NOT NULL,
    dronepresetid integer NOT NULL,
    typeid integer NOT NULL,
    quantityinbay integer NOT NULL,
    quantityinspace integer NOT NULL
);


--
-- Name: fittingmodules; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE fittingmodules (
    fittinghash character(40) NOT NULL,
    presetid integer NOT NULL,
    slottype character varying(127) NOT NULL,
    index integer NOT NULL,
    typeid integer NOT NULL,
    state integer NOT NULL
);


--
-- Name: fittingfittedtypes; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW fittingfittedtypes AS
    SELECT t.fittinghash, string_agg(DISTINCT (invtypes.typename)::text, ', '::text) AS typelist FROM (((SELECT fittingmodules.fittinghash, fittingmodules.typeid FROM fittingmodules UNION SELECT fittingcharges.fittinghash, fittingcharges.typeid FROM fittingcharges) UNION SELECT fittingdrones.fittinghash, fittingdrones.typeid FROM fittingdrones) t JOIN eve.invtypes ON ((t.typeid = invtypes.typeid))) GROUP BY t.fittinghash;


--
-- Name: flags; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE flags (
    flagid integer NOT NULL,
    flaggedbyaccountid integer NOT NULL,
    createdat integer NOT NULL,
    type integer NOT NULL,
    subtype integer NOT NULL,
    status integer NOT NULL,
    other text,
    target1 integer,
    target2 integer,
    target3 integer,
    CONSTRAINT flags_notempty_check CHECK ((((target1 IS NOT NULL) OR (target2 IS NOT NULL)) OR (target3 IS NOT NULL)))
);


--
-- Name: flags_flagid_seq; Type: SEQUENCE; Schema: osmium; Owner: -
--

CREATE SEQUENCE flags_flagid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flags_flagid_seq; Type: SEQUENCE OWNED BY; Schema: osmium; Owner: -
--

ALTER SEQUENCE flags_flagid_seq OWNED BY flags.flagid;


--
-- Name: invboosters; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW invboosters AS
    SELECT invtypes.typeid, invtypes.typename, (dta.value)::integer AS boosterness FROM ((eve.invtypes JOIN eve.invgroups ON ((invtypes.groupid = invgroups.groupid))) JOIN eve.dgmtypeattribs dta ON (((dta.attributeid = 1087) AND (dta.typeid = invtypes.typeid)))) WHERE ((((invgroups.categoryid = 20) AND (invtypes.groupid = 303)) AND (invgroups.published = true)) AND (invtypes.published = true));


--
-- Name: invcharges; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW invcharges AS
    SELECT modattribs.typeid AS moduleid, invtypes.typeid AS chargeid, invtypes.typename AS chargename FROM ((((eve.dgmtypeattribs modattribs LEFT JOIN eve.dgmtypeattribs modchargesize ON (((modchargesize.attributeid = 128) AND (modchargesize.typeid = modattribs.typeid)))) JOIN eve.invtypes ON (((modattribs.value)::integer = invtypes.groupid))) LEFT JOIN eve.dgmtypeattribs chargesize ON (((chargesize.attributeid = 128) AND (chargesize.typeid = invtypes.typeid)))) JOIN eve.invtypes modcapacity ON ((modcapacity.typeid = modattribs.typeid))) WHERE ((((modattribs.attributeid = ANY (ARRAY[604, 605, 606, 609, 610])) AND (((chargesize.value IS NULL) OR (modchargesize.value IS NULL)) OR (chargesize.value = modchargesize.value))) AND (modcapacity.capacity >= invtypes.volume)) AND (invtypes.published = true));


--
-- Name: invdrones; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW invdrones AS
    SELECT invtypes.typeid, invtypes.typename, invtypes.volume, invtypes.groupid, invgroups.groupname FROM (eve.invtypes JOIN eve.invgroups ON ((invtypes.groupid = invgroups.groupid))) WHERE (((invgroups.categoryid = 18) AND (invgroups.published = true)) AND (invtypes.published = true));


--
-- Name: invimplants; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW invimplants AS
    SELECT invtypes.typeid, invtypes.typename, (dta.value)::integer AS implantness FROM ((eve.invtypes JOIN eve.invgroups ON ((invtypes.groupid = invgroups.groupid))) JOIN eve.dgmtypeattribs dta ON (((dta.attributeid = 331) AND (dta.typeid = invtypes.typeid)))) WHERE ((((invgroups.categoryid = 20) AND (invtypes.groupid <> 303)) AND (invgroups.published = true)) AND (invtypes.published = true));


--
-- Name: invmodules; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW invmodules AS
    SELECT invtypes.typeid, invtypes.typename, COALESCE((invmetatypes.metagroupid)::integer, (metagroup.value)::integer, CASE (techlevel.value)::integer WHEN 2 THEN 2 WHEN 3 THEN 14 ELSE 1 END) AS metagroupid, invgroups.groupid, invgroups.groupname, invtypes.marketgroupid, invmarketgroups.marketgroupname FROM (((((eve.invtypes JOIN eve.invgroups ON ((invtypes.groupid = invgroups.groupid))) LEFT JOIN eve.invmarketgroups ON ((invtypes.marketgroupid = invmarketgroups.marketgroupid))) LEFT JOIN eve.invmetatypes ON ((invtypes.typeid = invmetatypes.typeid))) LEFT JOIN eve.dgmtypeattribs techlevel ON (((techlevel.typeid = invtypes.typeid) AND (techlevel.attributeid = 422)))) LEFT JOIN eve.dgmtypeattribs metagroup ON (((metagroup.typeid = invtypes.typeid) AND (metagroup.attributeid = 1692)))) WHERE (((invgroups.categoryid = ANY (ARRAY[7, 32])) AND (invgroups.published = true)) AND (invtypes.published = true));


--
-- Name: invmetagroups; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW invmetagroups AS
    SELECT DISTINCT invmetagroups.metagroupid, invmetagroups.metagroupname FROM (invmodules LEFT JOIN eve.invmetagroups ON ((invmodules.metagroupid = invmetagroups.metagroupid)));


--
-- Name: invships; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW invships AS
    SELECT invtypes.typeid, invtypes.typename, invtypes.groupid, invgroups.groupname, invtypes.marketgroupid, invmarketgroups.marketgroupname FROM ((eve.invtypes JOIN eve.invgroups ON ((invtypes.groupid = invgroups.groupid))) LEFT JOIN eve.invmarketgroups ON ((invtypes.marketgroupid = invmarketgroups.marketgroupid))) WHERE (((invgroups.categoryid = 6) AND (invgroups.published = true)) AND (invtypes.published = true));


--
-- Name: invskills; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW invskills AS
    SELECT invtypes.typeid, invtypes.typename, invtypes.groupid, invgroups.groupname FROM (eve.invtypes JOIN eve.invgroups ON ((invtypes.groupid = invgroups.groupid))) WHERE ((invgroups.categoryid = 16) AND (invtypes.published = true));


--
-- Name: loadoutcommentreplies; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE loadoutcommentreplies (
    commentreplyid integer NOT NULL,
    commentid integer NOT NULL,
    accountid integer NOT NULL,
    creationdate integer NOT NULL,
    replybody text NOT NULL,
    replyformattedbody text NOT NULL,
    updatedate integer,
    updatedbyaccountid integer
);


--
-- Name: loadoutcommentreplies_commentreplyid_seq; Type: SEQUENCE; Schema: osmium; Owner: -
--

CREATE SEQUENCE loadoutcommentreplies_commentreplyid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: loadoutcommentreplies_commentreplyid_seq; Type: SEQUENCE OWNED BY; Schema: osmium; Owner: -
--

ALTER SEQUENCE loadoutcommentreplies_commentreplyid_seq OWNED BY loadoutcommentreplies.commentreplyid;


--
-- Name: loadoutcommentrevisions; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE loadoutcommentrevisions (
    commentid integer NOT NULL,
    revision integer NOT NULL,
    updatedbyaccountid integer NOT NULL,
    updatedate integer NOT NULL,
    commentbody text NOT NULL,
    commentformattedbody text NOT NULL
);


--
-- Name: loadoutcomments; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE loadoutcomments (
    commentid integer NOT NULL,
    loadoutid integer NOT NULL,
    accountid integer NOT NULL,
    creationdate integer NOT NULL,
    revision integer NOT NULL
);


--
-- Name: loadoutcomments_commentid_seq; Type: SEQUENCE; Schema: osmium; Owner: -
--

CREATE SEQUENCE loadoutcomments_commentid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: loadoutcomments_commentid_seq; Type: SEQUENCE OWNED BY; Schema: osmium; Owner: -
--

ALTER SEQUENCE loadoutcomments_commentid_seq OWNED BY loadoutcomments.commentid;


--
-- Name: loadoutcommentslatestrevision; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW loadoutcommentslatestrevision AS
    SELECT loadoutcomments.commentid, max(loadoutcommentrevisions.revision) AS latestrevision FROM (loadoutcomments JOIN loadoutcommentrevisions ON ((loadoutcommentrevisions.commentid = loadoutcomments.commentid))) GROUP BY loadoutcomments.commentid;


--
-- Name: votes; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE votes (
    voteid integer NOT NULL,
    fromaccountid integer NOT NULL,
    fromeveaccountid integer NOT NULL,
    fromclientid integer NOT NULL,
    accountid integer NOT NULL,
    creationdate integer NOT NULL,
    cancellableuntil integer,
    reputationgiventodest integer,
    reputationgiventosource integer,
    type integer NOT NULL,
    targettype integer NOT NULL,
    targetid1 integer,
    targetid2 integer,
    targetid3 integer,
    CONSTRAINT votes_notaselfvote_check CHECK ((fromaccountid <> accountid)),
    CONSTRAINT votes_notempty_check CHECK ((((targetid1 IS NOT NULL) OR (targetid2 IS NOT NULL)) OR (targetid3 IS NOT NULL)))
);


--
-- Name: votecount; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW votecount AS
    SELECT count(votes.voteid) AS count, votes.type, votes.targettype, votes.targetid1, votes.targetid2, votes.targetid3 FROM votes GROUP BY votes.type, votes.targettype, votes.targetid1, votes.targetid2, votes.targetid3;


--
-- Name: loadoutcommentupdownvotes; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW loadoutcommentupdownvotes AS
    SELECT c.commentid, (COALESCE(uv.count, (0)::bigint) - COALESCE(dv.count, (0)::bigint)) AS votes, COALESCE(uv.count, (0)::bigint) AS upvotes, COALESCE(dv.count, (0)::bigint) AS downvotes FROM ((loadoutcomments c LEFT JOIN votecount uv ON ((((((uv.type = 1) AND (uv.targettype = 2)) AND (uv.targetid1 = c.commentid)) AND (uv.targetid2 = c.loadoutid)) AND (uv.targetid3 IS NULL)))) LEFT JOIN votecount dv ON ((((((dv.type = 2) AND (dv.targettype = 2)) AND (dv.targetid1 = c.commentid)) AND (dv.targetid2 = c.loadoutid)) AND (dv.targetid3 IS NULL))));


--
-- Name: loadouthistory; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE loadouthistory (
    loadoutid integer NOT NULL,
    revision integer NOT NULL,
    fittinghash character(40) NOT NULL,
    updatedbyaccountid integer NOT NULL,
    updatedate integer NOT NULL
);


--
-- Name: searchableloadouts; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW searchableloadouts AS
    SELECT allowedloadoutsbyaccount.accountid, allowedloadoutsbyaccount.loadoutid FROM (allowedloadoutsbyaccount JOIN loadouts ON ((allowedloadoutsbyaccount.loadoutid = loadouts.loadoutid))) WHERE ((loadouts.visibility = 0) AND (loadouts.viewpermission <> 0)) UNION SELECT 0 AS accountid, allowedloadoutsanonymous.loadoutid FROM (allowedloadoutsanonymous JOIN loadouts ON ((allowedloadoutsanonymous.loadoutid = loadouts.loadoutid))) WHERE (loadouts.visibility = 0);


--
-- Name: loadoutscores; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW loadoutscores AS
    SELECT searchableloadouts.loadoutid, COALESCE(uv.count, (0)::bigint) AS upvotes, COALESCE(dv.count, (0)::bigint) AS downvotes, ((((COALESCE((uv.count)::numeric, 0.5) + 1.9208) / (COALESCE((uv.count)::numeric, 0.5) + (COALESCE(dv.count, (0)::bigint))::numeric)) - ((1.96 * sqrt((((COALESCE((uv.count)::numeric, 0.5) * (COALESCE(dv.count, (0)::bigint))::numeric) / (COALESCE((uv.count)::numeric, 0.5) + (COALESCE(dv.count, (0)::bigint))::numeric)) + 0.9604))) / (COALESCE((uv.count)::numeric, 0.5) + (COALESCE(dv.count, (0)::bigint))::numeric))) / ((1)::numeric + (3.8416 / (COALESCE((uv.count)::numeric, 0.5) + (COALESCE(dv.count, (0)::bigint))::numeric)))) AS score FROM ((searchableloadouts LEFT JOIN votecount uv ON ((((((uv.type = 1) AND (uv.targettype = 1)) AND (uv.targetid1 = searchableloadouts.loadoutid)) AND (uv.targetid2 IS NULL)) AND (uv.targetid3 IS NULL)))) LEFT JOIN votecount dv ON ((((((dv.type = 2) AND (dv.targettype = 1)) AND (dv.targetid1 = searchableloadouts.loadoutid)) AND (dv.targetid2 IS NULL)) AND (dv.targetid3 IS NULL))));


--
-- Name: loadoutslatestrevision; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW loadoutslatestrevision AS
    SELECT loadouts.loadoutid, max(loadouthistory.revision) AS latestrevision FROM (loadouts JOIN loadouthistory ON ((loadouthistory.loadoutid = loadouts.loadoutid))) GROUP BY loadouts.loadoutid;


--
-- Name: loadoutssearchdata; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW loadoutssearchdata AS
    SELECT searchableloadouts.loadoutid, CASE loadouts.viewpermission WHEN 4 THEN accounts.accountid ELSE 0 END AS restrictedtoaccountid, CASE loadouts.viewpermission WHEN 3 THEN CASE accounts.apiverified WHEN true THEN accounts.corporationid ELSE (-1) END ELSE 0 END AS restrictedtocorporationid, CASE loadouts.viewpermission WHEN 2 THEN CASE accounts.apiverified WHEN true THEN accounts.allianceid ELSE (-1) END ELSE 0 END AS restrictedtoallianceid, fittingaggtags.taglist AS tags, fittingfittedtypes.typelist AS modules, CASE accounts.apiverified WHEN true THEN accounts.charactername ELSE accounts.nickname END AS author, fittings.name, fittingdescriptions.descriptions AS description, fittings.hullid AS shipid, invtypes.typename AS ship, fittings.creationdate, loadouthistory.updatedate, ls.upvotes, ls.downvotes, ls.score, invgroups.groupname AS groups FROM (((((((((((searchableloadouts JOIN loadoutslatestrevision ON ((searchableloadouts.loadoutid = loadoutslatestrevision.loadoutid))) JOIN loadouts ON ((loadoutslatestrevision.loadoutid = loadouts.loadoutid))) JOIN accounts ON ((loadouts.accountid = accounts.accountid))) JOIN loadouthistory ON (((loadouthistory.loadoutid = loadoutslatestrevision.loadoutid) AND (loadouthistory.revision = loadoutslatestrevision.latestrevision)))) JOIN fittings ON ((fittings.fittinghash = loadouthistory.fittinghash))) JOIN loadoutscores ls ON ((ls.loadoutid = searchableloadouts.loadoutid))) JOIN eve.invtypes ON ((invtypes.typeid = fittings.hullid))) LEFT JOIN fittingaggtags ON ((fittingaggtags.fittinghash = loadouthistory.fittinghash))) LEFT JOIN fittingfittedtypes ON ((fittingfittedtypes.fittinghash = loadouthistory.fittinghash))) LEFT JOIN fittingdescriptions ON ((fittingdescriptions.fittinghash = loadouthistory.fittinghash))) LEFT JOIN eve.invgroups ON ((invgroups.groupid = invtypes.groupid)));


--
-- Name: loadoutupdownvotes; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW loadoutupdownvotes AS
    SELECT l.loadoutid, (COALESCE(uv.count, (0)::bigint) - COALESCE(dv.count, (0)::bigint)) AS votes, COALESCE(uv.count, (0)::bigint) AS upvotes, COALESCE(dv.count, (0)::bigint) AS downvotes FROM ((loadouts l LEFT JOIN votecount uv ON ((((((uv.type = 1) AND (uv.targettype = 1)) AND (uv.targetid1 = l.loadoutid)) AND (uv.targetid2 IS NULL)) AND (uv.targetid3 IS NULL)))) LEFT JOIN votecount dv ON ((((((dv.type = 2) AND (dv.targettype = 1)) AND (dv.targetid1 = l.loadoutid)) AND (dv.targetid2 IS NULL)) AND (dv.targetid3 IS NULL))));


--
-- Name: log; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE log (
    logentryid integer NOT NULL,
    clientid integer NOT NULL,
    creationdate integer NOT NULL,
    type integer NOT NULL,
    subtype integer,
    target1 integer,
    target2 integer,
    target3 integer
);


--
-- Name: log_logentryid_seq; Type: SEQUENCE; Schema: osmium; Owner: -
--

CREATE SEQUENCE log_logentryid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_logentryid_seq; Type: SEQUENCE OWNED BY; Schema: osmium; Owner: -
--

ALTER SEQUENCE log_logentryid_seq OWNED BY log.logentryid;


--
-- Name: notifications; Type: TABLE; Schema: osmium; Owner: -; Tablespace: 
--

CREATE TABLE notifications (
    notificationid integer NOT NULL,
    accountid integer NOT NULL,
    creationdate integer NOT NULL,
    type integer NOT NULL,
    fromaccountid integer,
    targetid1 integer,
    targetid2 integer,
    targetid3 integer
);


--
-- Name: notifications_notificationid_seq; Type: SEQUENCE; Schema: osmium; Owner: -
--

CREATE SEQUENCE notifications_notificationid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_notificationid_seq; Type: SEQUENCE OWNED BY; Schema: osmium; Owner: -
--

ALTER SEQUENCE notifications_notificationid_seq OWNED BY notifications.notificationid;


--
-- Name: tagcount; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW tagcount AS
    SELECT ft.tagname, count(ft.fittinghash) AS count FROM ((((allowedloadoutsanonymous a JOIN loadoutslatestrevision llr ON ((a.loadoutid = llr.loadoutid))) JOIN loadouthistory lh ON (((lh.loadoutid = a.loadoutid) AND (lh.revision = llr.latestrevision)))) JOIN loadouts l ON ((l.loadoutid = a.loadoutid))) JOIN fittingtags ft ON ((ft.fittinghash = lh.fittinghash))) WHERE (l.visibility = 0) GROUP BY ft.tagname;


--
-- Name: typessearchdata; Type: VIEW; Schema: osmium; Owner: -
--

CREATE VIEW typessearchdata AS
    SELECT t.typeid, it.typename, t.category, t.subcategory, ig.groupname, COALESCE((imt.metagroupid)::integer, (dta_mg.value)::integer, CASE (dta_tl.value)::integer WHEN 2 THEN 2 WHEN 3 THEN 14 ELSE 1 END) AS metagroupid, img.marketgroupid, img.marketgroupname FROM (((((((((((SELECT invships.typeid, 'ship'::text AS category, (invships.groupname)::text AS subcategory FROM invships UNION SELECT invmodules.typeid, 'module'::text AS category, CASE dte.effectid WHEN 11 THEN 'low'::text WHEN 12 THEN 'medium'::text WHEN 13 THEN 'high'::text WHEN 2663 THEN 'rig'::text WHEN 3772 THEN 'subsystem'::text ELSE NULL::text END AS subcategory FROM (invmodules JOIN eve.dgmtypeeffects dte ON (((invmodules.typeid = dte.typeid) AND (dte.effectid = ANY (ARRAY[11, 12, 13, 2663, 3772])))))) UNION SELECT invcharges.chargeid AS typeid, 'charge'::text AS category, NULL::text AS subcategory FROM invcharges) UNION SELECT invdrones.typeid, 'drone'::text AS category, NULL::text AS subcategory FROM invdrones) UNION SELECT invimplants.typeid, 'implant'::text AS category, (invimplants.implantness)::text AS subcategory FROM invimplants) UNION SELECT invboosters.typeid, 'booster'::text AS category, (invboosters.boosterness)::text AS subcategory FROM invboosters) t JOIN eve.invtypes it ON ((it.typeid = t.typeid))) JOIN eve.invgroups ig ON ((it.groupid = ig.groupid))) LEFT JOIN eve.invmarketgroups img ON ((img.marketgroupid = it.marketgroupid))) LEFT JOIN eve.invmetatypes imt ON ((it.typeid = imt.typeid))) LEFT JOIN eve.dgmtypeattribs dta_tl ON (((dta_tl.typeid = it.typeid) AND (dta_tl.attributeid = 422)))) LEFT JOIN eve.dgmtypeattribs dta_mg ON (((dta_mg.typeid = it.typeid) AND (dta_mg.attributeid = 1692))));


--
-- Name: votes_voteid_seq; Type: SEQUENCE; Schema: osmium; Owner: -
--

CREATE SEQUENCE votes_voteid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_voteid_seq; Type: SEQUENCE OWNED BY; Schema: osmium; Owner: -
--

ALTER SEQUENCE votes_voteid_seq OWNED BY votes.voteid;


--
-- Name: accountid; Type: DEFAULT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY accounts ALTER COLUMN accountid SET DEFAULT nextval('accounts_accountid_seq'::regclass);


--
-- Name: clientid; Type: DEFAULT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY clients ALTER COLUMN clientid SET DEFAULT nextval('clients_clientid_seq'::regclass);


--
-- Name: eveaccountid; Type: DEFAULT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY eveaccounts ALTER COLUMN eveaccountid SET DEFAULT nextval('eveaccounts_eveaccountid_seq'::regclass);


--
-- Name: flagid; Type: DEFAULT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY flags ALTER COLUMN flagid SET DEFAULT nextval('flags_flagid_seq'::regclass);


--
-- Name: commentreplyid; Type: DEFAULT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY loadoutcommentreplies ALTER COLUMN commentreplyid SET DEFAULT nextval('loadoutcommentreplies_commentreplyid_seq'::regclass);


--
-- Name: commentid; Type: DEFAULT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY loadoutcomments ALTER COLUMN commentid SET DEFAULT nextval('loadoutcomments_commentid_seq'::regclass);


--
-- Name: logentryid; Type: DEFAULT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY log ALTER COLUMN logentryid SET DEFAULT nextval('log_logentryid_seq'::regclass);


--
-- Name: notificationid; Type: DEFAULT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN notificationid SET DEFAULT nextval('notifications_notificationid_seq'::regclass);


--
-- Name: voteid; Type: DEFAULT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY votes ALTER COLUMN voteid SET DEFAULT nextval('votes_voteid_seq'::regclass);


--
-- Name: accountcharacters_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accountcharacters
    ADD CONSTRAINT accountcharacters_pkey PRIMARY KEY (accountid, name);


--
-- Name: accountfavorites_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accountfavorites
    ADD CONSTRAINT accountfavorites_pkey PRIMARY KEY (accountid, loadoutid);


--
-- Name: accounts_accountname_uniq; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_accountname_uniq UNIQUE (accountname);


--
-- Name: accounts_characterid_uniq; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_characterid_uniq UNIQUE (characterid);


--
-- Name: accounts_charactername_uniq; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_charactername_uniq UNIQUE (charactername);


--
-- Name: accounts_nickname_uniq; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_nickname_uniq UNIQUE (nickname);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (accountid);


--
-- Name: accountsettings_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accountsettings
    ADD CONSTRAINT accountsettings_pkey PRIMARY KEY (accountid, key);


--
-- Name: clients_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (clientid);


--
-- Name: clients_uniq; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY clients
    ADD CONSTRAINT clients_uniq UNIQUE (remoteaddress, useragent, accept, loggedinaccountid);


--
-- Name: cookietokens_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cookietokens
    ADD CONSTRAINT cookietokens_pkey PRIMARY KEY (token);


--
-- Name: eveaccounts_creationdate_uniq; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY eveaccounts
    ADD CONSTRAINT eveaccounts_creationdate_uniq UNIQUE (creationdate);


--
-- Name: eveaccounts_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY eveaccounts
    ADD CONSTRAINT eveaccounts_pkey PRIMARY KEY (eveaccountid);


--
-- Name: fittingchargepresets_fittinghash_presetid_name_unique; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fittingchargepresets
    ADD CONSTRAINT fittingchargepresets_fittinghash_presetid_name_unique UNIQUE (fittinghash, presetid, name);


--
-- Name: fittingchargepresets_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fittingchargepresets
    ADD CONSTRAINT fittingchargepresets_pkey PRIMARY KEY (fittinghash, presetid, chargepresetid);


--
-- Name: fittingcharges_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fittingcharges
    ADD CONSTRAINT fittingcharges_pkey PRIMARY KEY (fittinghash, presetid, chargepresetid, slottype, index);


--
-- Name: fittingdeltas_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fittingdeltas
    ADD CONSTRAINT fittingdeltas_pkey PRIMARY KEY (fittinghash1, fittinghash2);


--
-- Name: fittingdronepresets_fittinghash_name_unique; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fittingdronepresets
    ADD CONSTRAINT fittingdronepresets_fittinghash_name_unique UNIQUE (fittinghash, name);


--
-- Name: fittingdronepresets_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fittingdronepresets
    ADD CONSTRAINT fittingdronepresets_pkey PRIMARY KEY (fittinghash, dronepresetid);


--
-- Name: fittingdrones_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fittingdrones
    ADD CONSTRAINT fittingdrones_pkey PRIMARY KEY (fittinghash, dronepresetid, typeid);


--
-- Name: fittingmodules_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fittingmodules
    ADD CONSTRAINT fittingmodules_pkey PRIMARY KEY (fittinghash, presetid, slottype, index);


--
-- Name: fittingpresets_fittinghash_name_unique; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fittingpresets
    ADD CONSTRAINT fittingpresets_fittinghash_name_unique UNIQUE (fittinghash, name);


--
-- Name: fittingpresets_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fittingpresets
    ADD CONSTRAINT fittingpresets_pkey PRIMARY KEY (fittinghash, presetid);


--
-- Name: fittings_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fittings
    ADD CONSTRAINT fittings_pkey PRIMARY KEY (fittinghash);


--
-- Name: fittingtags_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fittingtags
    ADD CONSTRAINT fittingtags_pkey PRIMARY KEY (fittinghash, tagname);


--
-- Name: flags_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY flags
    ADD CONSTRAINT flags_pkey PRIMARY KEY (flagid);


--
-- Name: loadoutcommentreplies_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY loadoutcommentreplies
    ADD CONSTRAINT loadoutcommentreplies_pkey PRIMARY KEY (commentreplyid);


--
-- Name: loadoutcommentrevisions_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY loadoutcommentrevisions
    ADD CONSTRAINT loadoutcommentrevisions_pkey PRIMARY KEY (commentid, revision);


--
-- Name: loadoutcomments_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY loadoutcomments
    ADD CONSTRAINT loadoutcomments_pkey PRIMARY KEY (commentid);


--
-- Name: loadouthistory_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY loadouthistory
    ADD CONSTRAINT loadouthistory_pkey PRIMARY KEY (loadoutid, revision);


--
-- Name: loadouts_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY loadouts
    ADD CONSTRAINT loadouts_pkey PRIMARY KEY (loadoutid);


--
-- Name: log_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log
    ADD CONSTRAINT log_pkey PRIMARY KEY (logentryid);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (notificationid);


--
-- Name: votes_fromaccountid_type_targettype_targetid1_targetid2_targeti; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_fromaccountid_type_targettype_targetid1_targetid2_targeti UNIQUE (fromaccountid, type, targettype, targetid1, targetid2, targetid3);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: osmium; Owner: -; Tablespace: 
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (voteid);


--
-- Name: accountcharacters_accountid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX accountcharacters_accountid_idx ON accountcharacters USING btree (accountid);


--
-- Name: accountfavorites_accountid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX accountfavorites_accountid_idx ON accountfavorites USING btree (accountid);


--
-- Name: accountfavorites_loadoutid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX accountfavorites_loadoutid_idx ON accountfavorites USING btree (loadoutid);


--
-- Name: accounts_accountname_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX accounts_accountname_idx ON accounts USING btree (accountname);


--
-- Name: accounts_allianceid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX accounts_allianceid_idx ON accounts USING btree (allianceid);


--
-- Name: accounts_apiverified_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX accounts_apiverified_idx ON accounts USING btree (apiverified);


--
-- Name: accounts_characterid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX accounts_characterid_idx ON accounts USING btree (characterid);


--
-- Name: accounts_corporationid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX accounts_corporationid_idx ON accounts USING btree (corporationid);


--
-- Name: accounts_isfittingmanager_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX accounts_isfittingmanager_idx ON accounts USING btree (isfittingmanager);


--
-- Name: accounts_ismoderator_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX accounts_ismoderator_idx ON accounts USING btree (ismoderator);


--
-- Name: accounts_nickname_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX accounts_nickname_idx ON accounts USING btree (nickname);


--
-- Name: accountsettings_accountid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX accountsettings_accountid_idx ON accountsettings USING btree (accountid);


--
-- Name: clients_accept_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX clients_accept_idx ON clients USING btree (accept);


--
-- Name: clients_loggedinaccountid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX clients_loggedinaccountid_idx ON clients USING btree (loggedinaccountid);


--
-- Name: clients_remoteaddress_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX clients_remoteaddress_idx ON clients USING btree (remoteaddress);


--
-- Name: clients_useragent_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX clients_useragent_idx ON clients USING btree (useragent);


--
-- Name: cookietokens_accountid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX cookietokens_accountid_idx ON cookietokens USING btree (accountid);


--
-- Name: cookietokens_expirationdate_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX cookietokens_expirationdate_idx ON cookietokens USING btree (expirationdate);


--
-- Name: fittingchargepresets_fittinghash_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX fittingchargepresets_fittinghash_idx ON fittingchargepresets USING btree (fittinghash);


--
-- Name: fittingchargepresets_fittinghash_presetid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX fittingchargepresets_fittinghash_presetid_idx ON fittingchargepresets USING btree (fittinghash, presetid);


--
-- Name: fittingcharges_fittinghash_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX fittingcharges_fittinghash_idx ON fittingcharges USING btree (fittinghash);


--
-- Name: fittingcharges_fittinghash_presetid_chargepresetid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX fittingcharges_fittinghash_presetid_chargepresetid_idx ON fittingcharges USING btree (fittinghash, presetid, chargepresetid);


--
-- Name: fittingcharges_fittinghash_presetid_slottype_index_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX fittingcharges_fittinghash_presetid_slottype_index_idx ON fittingcharges USING btree (fittinghash, presetid, slottype, index);


--
-- Name: fittingcharges_typeid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX fittingcharges_typeid_idx ON fittingcharges USING btree (typeid);


--
-- Name: fittingdeltas_fittinghash1_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX fittingdeltas_fittinghash1_idx ON fittingdeltas USING btree (fittinghash1);


--
-- Name: fittingdeltas_fittinghash2_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX fittingdeltas_fittinghash2_idx ON fittingdeltas USING btree (fittinghash2);


--
-- Name: fittingdronepresets_fittinghash_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX fittingdronepresets_fittinghash_idx ON fittingdronepresets USING btree (fittinghash);


--
-- Name: fittingdrones_fittinghash_dronepresetid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX fittingdrones_fittinghash_dronepresetid_idx ON fittingdrones USING btree (fittinghash, dronepresetid);


--
-- Name: fittingdrones_typeid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX fittingdrones_typeid_idx ON fittingdrones USING btree (typeid);


--
-- Name: fittingpresets_fittinghash_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX fittingpresets_fittinghash_idx ON fittingpresets USING btree (fittinghash);


--
-- Name: fittings_hullid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX fittings_hullid_idx ON fittings USING btree (hullid);


--
-- Name: fittingtags_fittinghash_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX fittingtags_fittinghash_idx ON fittingtags USING btree (fittinghash);


--
-- Name: fittingtags_tagname_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX fittingtags_tagname_idx ON fittingtags USING btree (tagname);


--
-- Name: flags_createdat_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX flags_createdat_idx ON flags USING btree (createdat);


--
-- Name: flags_flaggedbyaccountid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX flags_flaggedbyaccountid_idx ON flags USING btree (flaggedbyaccountid);


--
-- Name: flags_status_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX flags_status_idx ON flags USING btree (status);


--
-- Name: flags_subtype_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX flags_subtype_idx ON flags USING btree (subtype);


--
-- Name: flags_target1_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX flags_target1_idx ON flags USING btree (target1);


--
-- Name: flags_target2_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX flags_target2_idx ON flags USING btree (target2);


--
-- Name: flags_target3_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX flags_target3_idx ON flags USING btree (target3);


--
-- Name: flags_type_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX flags_type_idx ON flags USING btree (type);


--
-- Name: loadoutcommentreplies_accountid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadoutcommentreplies_accountid_idx ON loadoutcommentreplies USING btree (accountid);


--
-- Name: loadoutcommentreplies_commentid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadoutcommentreplies_commentid_idx ON loadoutcommentreplies USING btree (commentid);


--
-- Name: loadoutcommentreplies_creationdate_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadoutcommentreplies_creationdate_idx ON loadoutcommentreplies USING btree (creationdate);


--
-- Name: loadoutcommentreplies_updatedbyaccountid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadoutcommentreplies_updatedbyaccountid_idx ON loadoutcommentreplies USING btree (updatedbyaccountid);


--
-- Name: loadoutcommentrevisions_commentid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadoutcommentrevisions_commentid_idx ON loadoutcommentrevisions USING btree (commentid);


--
-- Name: loadoutcommentrevisions_revision_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadoutcommentrevisions_revision_idx ON loadoutcommentrevisions USING btree (revision);


--
-- Name: loadoutcommentrevisions_updatedbyaccountid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadoutcommentrevisions_updatedbyaccountid_idx ON loadoutcommentrevisions USING btree (updatedbyaccountid);


--
-- Name: loadoutcomments_accountid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadoutcomments_accountid_idx ON loadoutcomments USING btree (loadoutid);


--
-- Name: loadoutcomments_creationdate_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadoutcomments_creationdate_idx ON loadoutcomments USING btree (creationdate);


--
-- Name: loadoutcomments_loadoutid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadoutcomments_loadoutid_idx ON loadoutcomments USING btree (loadoutid);


--
-- Name: loadoutcomments_revision_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadoutcomments_revision_idx ON loadoutcomments USING btree (revision);


--
-- Name: loadouthistory_fittinghash_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadouthistory_fittinghash_idx ON loadouthistory USING btree (fittinghash);


--
-- Name: loadouthistory_loadoutid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadouthistory_loadoutid_idx ON loadouthistory USING btree (loadoutid);


--
-- Name: loadouthistory_updatedate_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadouthistory_updatedate_idx ON loadouthistory USING btree (updatedate);


--
-- Name: loadouthistory_updatedbyaccountid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadouthistory_updatedbyaccountid_idx ON loadouthistory USING btree (updatedbyaccountid);


--
-- Name: loadouts_accountid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadouts_accountid_idx ON loadouts USING btree (accountid);


--
-- Name: loadouts_editpermission_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadouts_editpermission_idx ON loadouts USING btree (editpermission);


--
-- Name: loadouts_viewpermission_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadouts_viewpermission_idx ON loadouts USING btree (viewpermission);


--
-- Name: loadouts_visibility_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX loadouts_visibility_idx ON loadouts USING btree (visibility);


--
-- Name: log_clientid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX log_clientid_idx ON log USING btree (clientid);


--
-- Name: log_creationdate_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX log_creationdate_idx ON log USING btree (creationdate);


--
-- Name: log_subtype_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX log_subtype_idx ON log USING btree (subtype);


--
-- Name: log_target1_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX log_target1_idx ON log USING btree (target1);


--
-- Name: log_target2_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX log_target2_idx ON log USING btree (target2);


--
-- Name: log_target3_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX log_target3_idx ON log USING btree (target3);


--
-- Name: log_type_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX log_type_idx ON log USING btree (type);


--
-- Name: notifications_accountid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX notifications_accountid_idx ON notifications USING btree (accountid);


--
-- Name: notifications_creationdate_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX notifications_creationdate_idx ON notifications USING btree (creationdate);


--
-- Name: notifications_fromaccountid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX notifications_fromaccountid_idx ON notifications USING btree (fromaccountid);


--
-- Name: notifications_targetid1_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX notifications_targetid1_idx ON notifications USING btree (targetid1);


--
-- Name: notifications_targetid2_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX notifications_targetid2_idx ON notifications USING btree (targetid2);


--
-- Name: notifications_targetid3_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX notifications_targetid3_idx ON notifications USING btree (targetid3);


--
-- Name: notifications_type_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX notifications_type_idx ON notifications USING btree (type);


--
-- Name: votes_accountid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX votes_accountid_idx ON votes USING btree (accountid);


--
-- Name: votes_cancellableuntil_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX votes_cancellableuntil_idx ON votes USING btree (cancellableuntil);


--
-- Name: votes_creationdate_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX votes_creationdate_idx ON votes USING btree (creationdate);


--
-- Name: votes_fromaccountid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX votes_fromaccountid_idx ON votes USING btree (fromaccountid);


--
-- Name: votes_fromclientid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX votes_fromclientid_idx ON votes USING btree (fromclientid);


--
-- Name: votes_fromeveaccountid_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX votes_fromeveaccountid_idx ON votes USING btree (fromeveaccountid);


--
-- Name: votes_targetid1_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX votes_targetid1_idx ON votes USING btree (targetid1);


--
-- Name: votes_targetid2_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX votes_targetid2_idx ON votes USING btree (targetid2);


--
-- Name: votes_targetid3_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX votes_targetid3_idx ON votes USING btree (targetid3);


--
-- Name: votes_targettype_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX votes_targettype_idx ON votes USING btree (targettype);


--
-- Name: votes_type_idx; Type: INDEX; Schema: osmium; Owner: -; Tablespace: 
--

CREATE INDEX votes_type_idx ON votes USING btree (type);


--
-- Name: accountcharacters_accountid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY accountcharacters
    ADD CONSTRAINT accountcharacters_accountid_fkey FOREIGN KEY (accountid) REFERENCES accounts(accountid);


--
-- Name: accountfavorites_accountid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY accountfavorites
    ADD CONSTRAINT accountfavorites_accountid_fkey FOREIGN KEY (accountid) REFERENCES accounts(accountid);


--
-- Name: accountfavorites_loadoutid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY accountfavorites
    ADD CONSTRAINT accountfavorites_loadoutid_fkey FOREIGN KEY (loadoutid) REFERENCES loadouts(loadoutid);


--
-- Name: accountsettings_accountid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY accountsettings
    ADD CONSTRAINT accountsettings_accountid_fkey FOREIGN KEY (accountid) REFERENCES accounts(accountid);


--
-- Name: clients_loggedinaccountid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY clients
    ADD CONSTRAINT clients_loggedinaccountid_fkey FOREIGN KEY (loggedinaccountid) REFERENCES accounts(accountid);


--
-- Name: cookietokens_accountid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY cookietokens
    ADD CONSTRAINT cookietokens_accountid_fkey FOREIGN KEY (accountid) REFERENCES accounts(accountid);


--
-- Name: fittingchargepresets_fittinghash_presetid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY fittingchargepresets
    ADD CONSTRAINT fittingchargepresets_fittinghash_presetid_fkey FOREIGN KEY (fittinghash, presetid) REFERENCES fittingpresets(fittinghash, presetid);


--
-- Name: fittingcharges_fittinghash_presetid_chargepresetid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY fittingcharges
    ADD CONSTRAINT fittingcharges_fittinghash_presetid_chargepresetid_fkey FOREIGN KEY (fittinghash, presetid, chargepresetid) REFERENCES fittingchargepresets(fittinghash, presetid, chargepresetid);


--
-- Name: fittingcharges_fittinghash_presetid_slottype_index_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY fittingcharges
    ADD CONSTRAINT fittingcharges_fittinghash_presetid_slottype_index_fkey FOREIGN KEY (fittinghash, presetid, slottype, index) REFERENCES fittingmodules(fittinghash, presetid, slottype, index);


--
-- Name: fittingcharges_typeid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY fittingcharges
    ADD CONSTRAINT fittingcharges_typeid_fkey FOREIGN KEY (typeid) REFERENCES eve.invtypes(typeid);


--
-- Name: fittingdeltas_fittinghash1_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY fittingdeltas
    ADD CONSTRAINT fittingdeltas_fittinghash1_fkey FOREIGN KEY (fittinghash1) REFERENCES fittings(fittinghash);


--
-- Name: fittingdeltas_fittinghash2_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY fittingdeltas
    ADD CONSTRAINT fittingdeltas_fittinghash2_fkey FOREIGN KEY (fittinghash2) REFERENCES fittings(fittinghash);


--
-- Name: fittingdronepresets_fittinghash_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY fittingdronepresets
    ADD CONSTRAINT fittingdronepresets_fittinghash_fkey FOREIGN KEY (fittinghash) REFERENCES fittings(fittinghash);


--
-- Name: fittingdrones_fittinghash_dronepresetid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY fittingdrones
    ADD CONSTRAINT fittingdrones_fittinghash_dronepresetid_fkey FOREIGN KEY (fittinghash, dronepresetid) REFERENCES fittingdronepresets(fittinghash, dronepresetid);


--
-- Name: fittingdrones_typeid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY fittingdrones
    ADD CONSTRAINT fittingdrones_typeid_fkey FOREIGN KEY (typeid) REFERENCES eve.invtypes(typeid);


--
-- Name: fittingmodules_fittinghash_presetid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY fittingmodules
    ADD CONSTRAINT fittingmodules_fittinghash_presetid_fkey FOREIGN KEY (fittinghash, presetid) REFERENCES fittingpresets(fittinghash, presetid);


--
-- Name: fittingmodules_typeid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY fittingmodules
    ADD CONSTRAINT fittingmodules_typeid_fkey FOREIGN KEY (typeid) REFERENCES eve.invtypes(typeid);


--
-- Name: fittingpresets_fittinghash_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY fittingpresets
    ADD CONSTRAINT fittingpresets_fittinghash_fkey FOREIGN KEY (fittinghash) REFERENCES fittings(fittinghash);


--
-- Name: fittings_hullid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY fittings
    ADD CONSTRAINT fittings_hullid_fkey FOREIGN KEY (hullid) REFERENCES eve.invtypes(typeid);


--
-- Name: fittingtags_fittinghash_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY fittingtags
    ADD CONSTRAINT fittingtags_fittinghash_fkey FOREIGN KEY (fittinghash) REFERENCES fittings(fittinghash);


--
-- Name: flags_flaggedbyaccountid; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY flags
    ADD CONSTRAINT flags_flaggedbyaccountid FOREIGN KEY (flaggedbyaccountid) REFERENCES accounts(accountid);


--
-- Name: loadoutcommentreplies_accountid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY loadoutcommentreplies
    ADD CONSTRAINT loadoutcommentreplies_accountid_fkey FOREIGN KEY (accountid) REFERENCES accounts(accountid);


--
-- Name: loadoutcommentreplies_commentid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY loadoutcommentreplies
    ADD CONSTRAINT loadoutcommentreplies_commentid_fkey FOREIGN KEY (commentid) REFERENCES loadoutcomments(commentid);


--
-- Name: loadoutcommentreplies_updatedbyaccountid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY loadoutcommentreplies
    ADD CONSTRAINT loadoutcommentreplies_updatedbyaccountid_fkey FOREIGN KEY (updatedbyaccountid) REFERENCES accounts(accountid);


--
-- Name: loadoutcommentrevisions_commentid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY loadoutcommentrevisions
    ADD CONSTRAINT loadoutcommentrevisions_commentid_fkey FOREIGN KEY (commentid) REFERENCES loadoutcomments(commentid);


--
-- Name: loadoutcommentrevisions_updatedbyaccountid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY loadoutcommentrevisions
    ADD CONSTRAINT loadoutcommentrevisions_updatedbyaccountid_fkey FOREIGN KEY (updatedbyaccountid) REFERENCES accounts(accountid);


--
-- Name: loadoutcomments_accountid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY loadoutcomments
    ADD CONSTRAINT loadoutcomments_accountid_fkey FOREIGN KEY (accountid) REFERENCES accounts(accountid);


--
-- Name: loadoutcomments_loadoutid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY loadoutcomments
    ADD CONSTRAINT loadoutcomments_loadoutid_fkey FOREIGN KEY (loadoutid) REFERENCES loadouts(loadoutid);


--
-- Name: loadoutcomments_loadoutid_revision_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY loadoutcomments
    ADD CONSTRAINT loadoutcomments_loadoutid_revision_fkey FOREIGN KEY (loadoutid, revision) REFERENCES loadouthistory(loadoutid, revision);


--
-- Name: loadouthistory_fittinghash_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY loadouthistory
    ADD CONSTRAINT loadouthistory_fittinghash_fkey FOREIGN KEY (fittinghash) REFERENCES fittings(fittinghash);


--
-- Name: loadouthistory_loadoutid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY loadouthistory
    ADD CONSTRAINT loadouthistory_loadoutid_fkey FOREIGN KEY (loadoutid) REFERENCES loadouts(loadoutid);


--
-- Name: loadouthistory_updatedbyaccountid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY loadouthistory
    ADD CONSTRAINT loadouthistory_updatedbyaccountid_fkey FOREIGN KEY (updatedbyaccountid) REFERENCES accounts(accountid);


--
-- Name: loadouts_accountid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY loadouts
    ADD CONSTRAINT loadouts_accountid_fkey FOREIGN KEY (accountid) REFERENCES accounts(accountid);


--
-- Name: log_clientid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY log
    ADD CONSTRAINT log_clientid_fkey FOREIGN KEY (clientid) REFERENCES clients(clientid);


--
-- Name: notifications_accountid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_accountid_fkey FOREIGN KEY (accountid) REFERENCES accounts(accountid);


--
-- Name: notifications_fromaccountid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_fromaccountid_fkey FOREIGN KEY (fromaccountid) REFERENCES accounts(accountid);


--
-- Name: votes_accountid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_accountid_fkey FOREIGN KEY (accountid) REFERENCES accounts(accountid);


--
-- Name: votes_fromaccountid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_fromaccountid_fkey FOREIGN KEY (fromaccountid) REFERENCES accounts(accountid);


--
-- Name: votes_fromclientid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_fromclientid_fkey FOREIGN KEY (fromclientid) REFERENCES clients(clientid);


--
-- Name: votes_fromeveaccountid_fkey; Type: FK CONSTRAINT; Schema: osmium; Owner: -
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_fromeveaccountid_fkey FOREIGN KEY (fromeveaccountid) REFERENCES eveaccounts(eveaccountid);


--
-- PostgreSQL database dump complete
--

