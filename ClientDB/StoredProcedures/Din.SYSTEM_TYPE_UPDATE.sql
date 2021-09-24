USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Din].[SYSTEM_TYPE_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(100),
	@SHORT	VARCHAR(20),
	@NOTE	VARCHAR(100),
	@REG	VARCHAR(50),
	@WEIGHT	BIT,
	@COMPLECT	BIT,
	@MASTER	INT,
	@SALARY	DECIMAL(8,4),
	@Synonyms   VarChar(Max)
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

		UPDATE Din.SystemType
		SET SST_NAME	=	@NAME,
			SST_SHORT	=	@SHORT,
			SST_NOTE	=	@NOTE,
			SST_REG		=	@REG,
			SST_WEIGHT	=	@WEIGHT,
			SST_COMPLECT	=	@COMPLECT,
			SST_ID_MASTER	=	@MASTER,
			SST_SALARY		=	@SALARY
		WHERE SST_ID = @ID

		EXEC [Din].[SystemType:Synonyms@Save]
		    @Type_Id    = @ID,
		    @Synonyms   = @Synonyms;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Din].[SYSTEM_TYPE_UPDATE] TO rl_din_system_type_u;
GO
