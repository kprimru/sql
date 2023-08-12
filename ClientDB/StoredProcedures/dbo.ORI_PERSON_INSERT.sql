USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ORI_PERSON_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ORI_PERSON_INSERT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[ORI_PERSON_INSERT]
	@CLIENT	INT,
	@NAME	VARCHAR(250),
	@PHONE	VARCHAR(250),
	@PLACE	VARCHAR(100),
	@ID	INT = NULL OUTPUT
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

		INSERT INTO dbo.OriPersonTable(ClientID, OriPersonName, OriPersonPhone, OriPersonPlace)
			VALUES(@CLIENT, @NAME, @PHONE, @PLACE)

		SELECT @ID = SCOPE_IDENTITY()

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ORI_PERSON_INSERT] TO rl_ori_person_i;
GO
