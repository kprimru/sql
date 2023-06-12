﻿USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[ReRaise Error]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[ReRaise Error]  AS SELECT 1')
GO
ALTER PROCEDURE [Maintenance].[ReRaise Error]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @ErrorMessage   NVarChar(2048),
        @ErrorSeverity  Int,
        @ErrorState     Int;

    SET @ErrorSeverity  = ERROR_SEVERITY();
    SET @ErrorState     = ERROR_STATE();

    INSERT INTO Security.ErrorLog(NUM, PROC_NAME, MESSAGE)
    SELECT ERROR_NUMBER(), ERROR_PROCEDURE(), ERROR_MESSAGE();

    SET @ErrorMessage =
        'Ошибка в процедуре "'+ IsNull(ERROR_PROCEDURE(), '') + '". ' +
                                IsNull(ERROR_MESSAGE(), '') + ' (' +
                                IsNull('№ ошибки: ' + Cast(ERROR_NUMBER() AS NVarChar(10)), '') +
                                IsNull(' строка ' + Cast(ERROR_LINE() AS NVarChar(10)), '') + ')';

    RaisError(@ErrorMessage, @ErrorSeverity, @ErrorState)
END
GO
