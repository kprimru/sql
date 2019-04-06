USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Distr].[TECH_TYPE_UPDATE]
	@TT_ID		UNIQUEIDENTIFIER,
	@TT_NAME	VARCHAR(50),
	@TT_SHORT	VARCHAR(50),
	@TT_REG		INT,
	@TT_COEF	DECIMAL(8, 4),
	@TT_DATE	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @TT_ID_MASTER UNIQUEIDENTIFIER
	
	SELECT @TT_ID_MASTER = TT_ID_MASTER
	FROM Distr.TechTypeDetail
	WHERE TT_ID = @TT_ID

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'TECH_TYPE', @TT_ID_MASTER, @OLD OUTPUT


	UPDATE	Distr.TechTypeDetail
	SET		TT_NAME		=	@TT_NAME,
			TT_SHORT	=	@TT_SHORT,
			TT_REG		=	@TT_REG,
			TT_COEF		=	@TT_COEF,
			TT_DATE		=	@TT_DATE
	WHERE	TT_ID		=	@TT_ID 

	UPDATE	Distr.TechType
	SET		TTMS_LAST	=	GETDATE()
	WHERE	TTMS_ID =
		(
			SELECT	TT_ID_MASTER
			FROM	Distr.TechTypeDetail	
			WHERE	TT_ID	=	@TT_ID
		)

	EXEC Common.PROTOCOL_VALUE_GET 'TECH_TYPE', @TT_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'TECH_TYPE', '��������������', @TT_ID_MASTER, @OLD, @NEW

END

