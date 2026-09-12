-- DROP PROCEDURE public.sp_annexure_offer_letter_insupd(in int4, in int4, in varchar, in varchar, in int4, in int4, in int4, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_annexure_offer_letter_insupd(IN _annexureofferletterid integer, IN _companyid integer, IN _templatename character varying, IN _filepath character varying, IN _fileid integer, IN _adminid integer, IN _lettertype integer, OUT _processingresult character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR;
    _letterid integer;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM annexure_offer_letter WHERE annexureofferletterid = _annexureofferletterid) THEN
        SELECT COALESCE(MAX(annexureofferletterid), 0) + 1 
        INTO _letterid 
        FROM annexure_offer_letter;

        INSERT INTO annexure_offer_letter (
            annexureofferletterid,
            companyid,
            templatename,
            filepath,
            fileid,
            lettertype,
            createdby,
            createdon,
            updatedby,
            updatedon
        ) VALUES (
            _letterid,
            _companyid, 
            _templatename, 
            _filepath,
            _fileid,
            _lettertype,
            _adminid,
            timezone('utc', now()),
            NULL,
            NULL
        );
        
        _processingresult := _letterid::varchar;
    ELSE
        _letterid := _annexureofferletterid;
        
        UPDATE annexure_offer_letter SET 
            companyid = _companyid,
            templatename = _templatename, 
            filepath = _filepath,
            fileid = _fileid,
            lettertype = _lettertype,
            updatedby = _adminid,
            updatedon = timezone('utc', now())
        WHERE annexureofferletterid = _annexureofferletterid;
        
        _processingresult := _letterid::varchar;
    END IF;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(
        _message::text, 
        ''::text, 
        'sp_annexure_offer_letter_insupd'::varchar, 
        B'1', 
        B'0', 
        _result
    );
END;
$procedure$
;
