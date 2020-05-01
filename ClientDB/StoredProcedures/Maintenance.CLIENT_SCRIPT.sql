USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Maintenance].[CLIENT_SCRIPT]
	@ID		INT,
	@SQL	NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		--DECLARE @SQL NVARCHAR(MAX)

		SELECT @SQL = N'
			INSERT INTO dbo.ClientTable(
						ClientShortName, ClientFullName, ClientINN, ClientServiceID, ClientActivity, StatusID, ClientNote,
						ServiceTypeID, RangeID, ClientEmail, ClientPlace, ClientOfficial, ClientMainBook, ClientNewspaper)
				SELECT ''' + ISNULL(ClientShortName, '') + ''', ''' + ISNULL(ClientFullName, '') + ''', ''' + ClientINN + ''',
					(SELECT TOP 1 ServiceID FROM dbo.ServiceTable WHERE ServiceDismiss IS NULL),
					''' + ISNULL(Clientactivity, '') + ''', 2, ''' + ISNULL(ClientNote, '') + ''',
					(SELECT TOP 1 ServiceTypeID FROM dbo.ServiceTypeTable),
					(SELECT TOP 1 RangeID FROM dbo.RangeTable),
					''' + ISNULL(ClientEmail, '') + ''', ''' + ISNULL(ClientPlace, '') + ''', ''' + ISNULL(ClientOfficial, '') + ''', 0, 0'
		FROM dbo.ClientTable
		WHERE ClientID = @ID

		SET @SQL = @SQL + '
			SELECT @ID = SCOPE_IDENTITY()
		'

		SELECT @SQL = @SQL + '
			INSERT INTO dbo.ClientAddress(CA_ID_CLIENT, CA_ID_TYPE, CA_NAME, CA_INDEX, CA_ID_STREET, CA_HOME, CA_OFFICE, CA_HINT, CA_NOTE)
				SELECT @ID, (SELECT TOP 1 AT_ID FROM dbo.AddressType WHERE AT_REQUIRED = 1), ''' + ISNULL(CA_NAME, '') + ''', ''' + ISNULL(CA_INDEX, '') + ''',
						(
							SELECT TOP 1 ST_ID
							FROM dbo.StreetView
							WHERE ST_NAME = ''' + ST_NAME + ''' AND CT_NAME = ''' + CT_NAME + '''
						), ''' + ISNULL(CA_HOME, '') + ''', ''' + ISNULL(CA_OFFICE, '') + ''', ''' + ISNULL(CA_HINT, '') + ''', ''' + ISNULL(CA_NOTE, '') + ''''
		FROM
			dbo.ClientAddress
			INNER JOIN dbo.StreetView ON CA_ID_STREET = ST_ID
		WHERE CA_ID_CLIENT = @ID
			AND CA_ID_TYPE = '151ea013-03c0-e111-8db0-000c2986905f'

		SELECT @SQL = @SQL + '
			INSERT INTO dbo.ClientPersonal(CP_ID_CLIENT, CP_ID_TYPE, CP_SURNAME, CP_NAME, CP_PATRON, CP_POS, CP_NOTE, CP_EMAIL, CP_PHONE, CP_FAX, CP_PHONE_S)
				SELECT
					@ID, (SELECT CPT_ID FROM dbo.ClientPersonalType WHERE CPT_PSEDO = ''' + ISNULL(CPT_PSEDO, '') + '''),
					''' + CP_SURNAME + ''', ''' + CP_NAME + ''', ''' + CP_PATRON + ''', ''' + CP_POS + ''', ''' + CP_NOTE + ''', ''' + ISNULL(CP_EMAIL, '') + ''',
					''' + CP_PHONE + ''', ''' + ISNULL(CP_FAX, '') + ''', ''' + ISNULL(CP_PHONE_S, '') + ''''
		FROM
			dbo.ClientPersonal
			INNER JOIN dbo.ClientPersonalType ON CPT_ID = CP_ID_TYPE
		WHERE CP_ID_CLIENT = @ID

		--PRINT @SQL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
