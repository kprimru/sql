USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_ADDRESS_SELECT]
	@ID	INT
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

		SELECT
			a.CA_ID, AT_ID, AT_NAME, b.AT_REQUIRED, CA_INDEX, ST_ID, ST_STR, CA_HOME, CA_OFFICE, CA_HINT, CA_NOTE, DS_ID, DS_NAME,
			CASE
				WHEN CA_ID_STREET IS NULL THEN ''
				ELSE CA_STR
			END AS CA_STR,
			/*ISNULL(ST_STR + ', ', '') + ISNULL(CA_HOME + ', ', '') + ISNULL(CA_OFFICE, '') AS CA_STR, */
			CA_NAME, CA_MAP, 
			CASE
				WHEN CA_MAP IS NULL THEN 'Нет'
				ELSE 'Есть'
			END AS CA_MAP_EXISTS
		FROM
			dbo.ClientAddress a
			INNER JOIN dbo.AddressType b ON CA_ID_TYPE = AT_ID
			LEFT OUTER JOIN dbo.StreetView ON CA_ID_STREET = ST_ID
			LEFT OUTER JOIN dbo.District ON DS_ID = CA_ID_DISTRICT
			LEFT OUTER JOIN dbo.ClientAddressFullView z ON z.CA_ID = a.CA_ID
		WHERE a.CA_ID_CLIENT = @ID
		ORDER BY AT_REQUIRED DESC, CA_NAME, ST_STR
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END