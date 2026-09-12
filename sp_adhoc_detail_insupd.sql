-- DROP PROCEDURE public.sp_adhoc_detail_insupd(in int4, in varchar, in varchar, in int8, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_adhoc_detail_insupd(IN _adhocid integer, IN _name character varying, IN _description character varying, IN _adminid bigint, OUT _processingresult character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR;
BEGIN
    IF NOT EXISTS(SELECT 1 FROM adhoc_detail WHERE adhocid = _adhocid) THEN
        INSERT INTO adhoc_detail (
            name,
            description,
            createdon,
            updatedon,
            createdby,
            updatedby
        ) VALUES (
            _name,
            _description,
            timezone('utc', now()),
            NULL,
            _adminid,
            NULL
        );
        
        _processingresult := 'inserted';
    ELSE
        UPDATE adhoc_detail SET 
            name = _name,
            description = _description,
            updatedby = _adminid,
            updatedon = timezone('utc', now())
        WHERE adhocid = _adhocid;
        
        _processingresult := 'updated';
    END IF;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(
        _message::text, 
        ''::text, 
        'sp_adhoc_detail_insupd'::varchar, 
        B'1', 
        B'0', 
        _result
    );
END;
$procedure$
;
