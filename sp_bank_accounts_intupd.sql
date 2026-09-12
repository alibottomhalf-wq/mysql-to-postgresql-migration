-- DROP PROCEDURE public.sp_bank_accounts_intupd(in int4, in int4, in int4, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in timestamp, in bit, in int8, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_bank_accounts_intupd(IN _bankaccountid integer, IN _organizationid integer, IN _companyid integer, IN _bankname character varying, IN _branchcode character varying, IN _branch character varying, IN _ifsc character varying, IN _accountno character varying, IN _openingdate timestamp without time zone, IN _closingdate timestamp without time zone, IN _isprimaryaccount bit, IN _adminid bigint, OUT _processingresult character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR;
    _target_id bigint;
BEGIN
    _processingresult := '';

    -- Reset other accounts if setting this one as primary
    IF (_isprimaryaccount = B'1') THEN 
        UPDATE bank_accounts 
        SET isprimaryaccount = B'0'
        WHERE companyid = _companyid;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM bank_accounts WHERE bankaccountid = _bankaccountid) THEN
        SELECT COALESCE(MAX(bankaccountid), 0) + 1 
        INTO _target_id 
        FROM bank_accounts;

        INSERT INTO bank_accounts (
            bankaccountid,
            organizationid,
            companyid,
            bankname,
            branchcode,
            branch,
            ifsc,
            accountno,
            openingdate,
            closingdate,
            isprimaryaccount,
            createdby,
            updatedby,
            createdon,
            updatedon
        ) VALUES (
            _target_id,
            _organizationid,
            _companyid,
            _bankname,
            _branchcode,
            _branch, 
            _ifsc,
            _accountno,
            _openingdate,
            _closingdate,
            _isprimaryaccount,
            _adminid,
            NULL,
            timezone('utc', now()),
            NULL
        );
        
        _processingresult := 'inserted';
    ELSE 
        UPDATE bank_accounts 
        SET
            organizationid = _organizationid,
            companyid = _companyid,
            bankname = _bankname,
            branchcode = _branchcode,
            branch = _branch,
            ifsc = _ifsc,
            accountno = _accountno,
            openingdate = _openingdate,
            closingdate = _closingdate,
            isprimaryaccount = _isprimaryaccount,
            updatedby = _adminid,
            updatedon = timezone('utc', now())
        WHERE bankaccountid = _bankaccountid;
        
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
        'sp_bank_accounts_intupd'::varchar, 
        B'1', 
        B'0', 
        _result
    );
END;
$procedure$
;
