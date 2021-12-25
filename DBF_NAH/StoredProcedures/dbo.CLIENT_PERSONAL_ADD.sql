USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_PERSONAL_ADD]
	@clientid INT,
	@surname VARCHAR(100),
	@name VARCHAR(100),
	@otch VARCHAR(100),
	@positionid SMALLINT,
	@reportpositionid SMALLINT,
	--  @phone varchar(100),
	@returnvalue BIT = 1
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

		INSERT INTO dbo.ClientPersonalTable(PER_ID_CLIENT, PER_FAM, PER_NAME, PER_OTCH, PER_ID_POS, PER_ID_REPORT_POS)
		VALUES (@clientid, @surname, @name, @otch, @positionid, @reportpositionid)

		IF @returnvalue = 1
			SELECT SCOPE_IDENTITY() AS NEW_IDEN

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_ADD] TO rl_client_personal_w;
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_ADD] TO rl_client_w;
GO
