USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Din].[NET_TYPE_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(100),
	@NOTE	VARCHAR(50),
	@NET	SMALLINT,
	@TECH	SMALLINT,
	@SHORT	VARCHAR(20),
	@MASTER	INT,
	@VMI_SHORT	VARCHAR(50),
	@ODOFF	SMALLINT,
	@ODON	SMALLINT,
	@TECH_USR	VARCHAR(20)
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

		UPDATE Din.NetType
		SET NT_NAME		=	@NAME,
			NT_NOTE		=	@NOTE,
			NT_NET		=	@NET,
			NT_TECH		=	@TECH,
			NT_SHORT	=	@SHORT,
			NT_ID_MASTER	=	@MASTER,
			NT_VMI_SHORT	=	@VMI_SHORT,
			NT_ODOFF		=	@ODOFF,
			NT_ODON			= @ODON,
			NT_TECH_USR		= @TECH_USR
		WHERE NT_ID	= @ID
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END