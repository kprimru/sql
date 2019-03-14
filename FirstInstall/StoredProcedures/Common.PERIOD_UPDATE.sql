USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Common].[PERIOD_UPDATE]
	@PR_ID			UNIQUEIDENTIFIER,
	@PR_NAME		VARCHAR(50),
	@PR_BEGIN_DATE	SMALLDATETIME,
	@PR_END_DATE	SMALLDATETIME,
	@PR_DATE		SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @PR_ID_MASTER UNIQUEIDENTIFIER
	
	SELECT @PR_ID_MASTER = PR_ID_MASTER
	FROM Common.PeriodDetail
	WHERE PR_ID = @PR_ID

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'PERIOD', @PR_ID_MASTER, @OLD OUTPUT


	UPDATE	Common.PeriodDetail
	SET		PR_NAME			=	@PR_NAME,
			PR_BEGIN_DATE	=	@PR_BEGIN_DATE,
			PR_END_DATE		=	@PR_END_DATE,
			PR_DATE			=	@PR_DATE
	WHERE	PR_ID			=	@PR_ID 

	UPDATE	Common.Period
	SET		PRMS_LAST	=	GETDATE()
	WHERE	PRMS_ID	=
		(
			SELECT	PR_ID_MASTER
			FROM	Common.PeriodDetail	
			WHERE	PR_ID	=	@PR_ID
		)

	EXEC Common.PROTOCOL_VALUE_GET 'PERIOD', @PR_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'PERIOD', '��������������', @PR_ID_MASTER, @OLD, @NEW

END

