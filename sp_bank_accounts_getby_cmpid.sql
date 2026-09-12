CREATE OR REPLACE PROCEDURE public.sp_bank_accounts_getby_cmpid(
    _searchstring character varying, 
    _sortby character varying, 
    _pageindex integer, 
    _pagesize integer,
    INOUT _cursor refcursor DEFAULT 'ref_result'
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR;
    _selectquery TEXT;
    _condition TEXT;
    _offset integer;
BEGIN
    -- Set default sorting
    IF (_sortby IS NULL OR TRIM(_sortby) = '') THEN
        _sortby := 'updatedon DESC NULLS LAST, createdon DESC';
    END IF;

    -- Set default search filter
    _condition := COALESCE(NULLIF(TRIM(_searchstring), ''), '1=1');

    -- Safe pagination defaults
    _pageindex := COALESCE(NULLIF(_pageindex, 0), 1);
    _pagesize := COALESCE(NULLIF(_pagesize, 0), 10);
    _offset := (_pageindex - 1) * _pagesize;

    _selectquery := '
        SELECT 
            b.bankaccountid,
            b.companyid,
            b.accountnumber,
            b.bankname,
            b.ifsccode,
            b.branchname,
            b.accounttype,
            b.isactive,
            b.createdby,
            b.createdon,
            b.updatedby,
            b.updatedon,
            COUNT(1) OVER() AS total
        FROM bank_accounts b
        WHERE ' || _condition || '
        ORDER BY ' || _sortby || '
        LIMIT ' || _pagesize || ' OFFSET ' || _offset;

    OPEN _cursor FOR EXECUTE _selectquery;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(
        _message::text, 
        ''::text, 
        'sp_bank_accounts_getby_cmpid'::varchar, 
        B'1', 
        B'0', 
        _result
    );
END;
$procedure$;
