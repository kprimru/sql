USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Din].[SYSTEM_TYPE_INSERT]	
	@NAME	VARCHAR(100),
	@SHORT	VARCHAR(20),
	@NOTE	VARCHAR(100),
	@REG	VARCHAR(50),
	@WEIGHT	BIT,
	@COMPLECT	BIT,
	@MASTER	INT,
	@SALARY	DECIMAL(8,4),
	@ID		INT = NULL OUTPUT
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

		INSERT INTO Din.SystemType(SST_NAME, SST_SHORT, SST_NOTE, SST_REG, SST_WEIGHT, SST_COMPLECT, SST_ID_MASTER, SST_SALARY)
			VALUES(@NAME, @SHORT, @NOTE, @REG, @WEIGHT, @COMPLECT, @MASTER, @SALARY)
		
		SELECT @ID = SCOPE_IDENTITY()
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END