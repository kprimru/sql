USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Maintenance].[ReRaise Error]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@ErrorMessage	NVarChar(2048),
		@ErrorSeverity	Int,
		@ErrorState		Int;

    SET @ErrorSeverity	= ERROR_SEVERITY();
    SET @ErrorState		= ERROR_STATE();


	SET @ErrorMessage =
		'������ � ��������� "'+ IsNull(ERROR_PROCEDURE(), '') + '". ' +
								IsNull(ERROR_MESSAGE(), '') + ' (' +
								IsNull('� ������: ' + Cast(ERROR_NUMBER() AS NVarChar(10)), '') +
								IsNull(' ������ ' + Cast(ERROR_LINE() AS NVarChar(10)), '') + ')';

	RaisError(@ErrorMessage, @ErrorSeverity, @ErrorState)
END
GO
