USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:		  Денисов Алексей
Описание:
*/
ALTER PROCEDURE [dbo].[CLIENT_ADDRESS_EDIT]
	@addressid INT,
	@streetid INT,
	@index VARCHAR(100),
	@home VARCHAR(100),
	@addresstypeid SMALLINT,
	@addressstr VARCHAR(500),
	@templateid SMALLINT = null,
	@free VARCHAR(500) = null
AS

BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		UPDATE dbo.ClientAddressTable
		SET CA_ID_TYPE = @addresstypeid,
			CA_ID_STREET = @streetid,
			CA_HOME = @home,
			CA_INDEX = @index,
			CA_STR = @addressstr,
			CA_ID_TEMPLATE = @templateid,
			CA_FREE = @free
		WHERE CA_ID = @addressid

		IF @templateid IS NOT NULL
			INSERT INTO dbo.ClientFinancingAddressTable(CFA_ID_CLIENT, CFA_ID_FAT, CFA_ID_ATL)
				SELECT
					(
						SELECT CA_ID_CLIENT
						FROM dbo.ClientAddressTable
						WHERE CA_ID = @addressid
					), FAT_ID, @templateid
				FROM dbo.FinancingAddressTypeTable
				WHERE ISNULL(FAT_ID_ADDR_TYPE, @addresstypeid) = @addresstypeid
					AND NOT EXISTS
						(
							SELECT *
							FROM dbo.ClientFinancingAddressTable
							WHERE CFA_ID_CLIENT =
								(
									SELECT CA_ID_CLIENT
									FROM dbo.ClientAddressTable
									WHERE CA_ID = @addressid
								)
								AND CFA_ID_FAT = FAT_ID
						)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_ADDRESS_EDIT] TO rl_client_address_w;
GRANT EXECUTE ON [dbo].[CLIENT_ADDRESS_EDIT] TO rl_client_w;
GO