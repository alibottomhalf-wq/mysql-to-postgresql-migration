-- DROP PROCEDURE public.sp_application_setting_insupd(in int4, in int4, in int4, in int4, in text, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_application_setting_insupd(IN _applicationsettingid integer, IN _organizationid integer, IN _companyid integer, IN _settingscatagoryid integer, IN _settingdetails text, OUT _processingresult character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR;
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM application_setting 
        WHERE applicationsettingid = _applicationsettingid
    ) THEN
        SELECT COALESCE(MAX(applicationsettingid), 0) + 1 
        INTO _applicationsettingid 
        FROM application_setting;

        INSERT INTO application_setting (
            applicationsettingid,
            organizationid,
            companyid,
            settingscatagoryid,
            settingdetails
        ) VALUES (
            _applicationsettingid,
            _organizationid,
            _companyid,
            _settingscatagoryid,
            _settingdetails
        );
        
        _processingresult := 'inserted';
    ELSE
        UPDATE application_setting 
        SET 
            organizationid = _organizationid,
            companyid = _companyid,
            settingscatagoryid = _settingscatagoryid,
            settingdetails = _settingdetails
        WHERE applicationsettingid = _applicationsettingid;
        
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
        'sp_application_setting_insupd'::varchar, 
        B'1', 
        B'0', 
        _result
    );
END;
$procedure$
;
