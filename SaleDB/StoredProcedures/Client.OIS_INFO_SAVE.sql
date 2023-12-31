USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[OIS_INFO_SAVE]
	@ID				UNIQUEIDENTIFIER,
	@COMPANY		UNIQUEIDENTIFIER,
	@COMPLECT		NVARCHAR(MAX),
	@TP				NVARCHAR(MAX),
	@SERVICE		NVARCHAR(MAX),
	@LPR			NVARCHAR(MAX),
	@WORK_PERSONAL	NVARCHAR(MAX),
	@CONS_PERSONAL	NVARCHAR(MAX),
	@RIVAL			NVARCHAR(MAX),
	@RIVAL_PARALLEL	NVARCHAR(MAX),
	@CONDITIONS		NVARCHAR(MAX),
	@ACITVITY		NVARCHAR(MAX),
	@NOTE			NVARCHAR(MAX),
	@SALE_DATE		SMALLDATETIME,
	@SERVICE_DATE	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	IF @ID IS NULL
		INSERT INTO Client.OISInfo(ID_COMPANY, COMPLECT, TP, SERVICE, LPR, WORK_PERSONAL, CONS_PERSONAL, RIVAL, RIVAL_PARALLEL, CONDITIONS, ACITVITY, NOTE, SALE_DATE, SERVICE_DATE)
			VALUES(@COMPANY, @COMPLECT, @TP, @SERVICE, @LPR, @WORK_PERSONAL, @CONS_PERSONAL, @RIVAL, @RIVAL_PARALLEL, @CONDITIONS, @ACITVITY, @NOTE, @SALE_DATE, @SERVICE_DATE)
	ELSE
		UPDATE Client.OISInfo
		SET COMPLECT		=	@COMPLECT,
			TP				=	@TP,
			SERVICE			=	@SERVICE,
			LPR				=	@LPR,
			WORK_PERSONAL	=	@WORK_PERSONAL,
			CONS_PERSONAL	=	@CONS_PERSONAL,
			RIVAL			=	@RIVAL,
			RIVAL_PARALLEL	=	@RIVAL_PARALLEL,
			CONDITIONS		=	@CONDITIONS,
			ACITVITY		=	@ACITVITY,
			NOTE			=	@NOTE,
			SALE_DATE		=	@SALE_DATE,
			SERVICE_DATE	=	@SERVICE_DATE
		WHERE ID = @ID
END

GO
GRANT EXECUTE ON [Client].[OIS_INFO_SAVE] TO rl_client_ois_w;
GO
