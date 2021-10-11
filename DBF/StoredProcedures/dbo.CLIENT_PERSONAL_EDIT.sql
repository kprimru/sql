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

ALTER PROCEDURE [dbo].[CLIENT_PERSONAL_EDIT]
	@personalid INT,
	@surname VARCHAR(100),
	@name VARCHAR(100),
	@otch VARCHAR(100),
	@positionid SMALLINT,
	@reportpositionid SMALLINT
--  @phone varchar(100)
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

		UPDATE dbo.ClientPersonalTable
		SET	PER_FAM = @surname, PER_NAME = @name, PER_OTCH = @otch,
			PER_ID_POS = @positionid, PER_ID_REPORT_POS = @reportpositionid
		--, PER_PHONE = @phone
		WHERE PER_ID = @personalid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_EDIT] TO rl_client_personal_w;
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_EDIT] TO rl_client_w;
GO
