USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[TECH_TYPE_OVER_ONE]
	@IDLIST	UNIQUEIDENTIFIER,
	@DATE	SMALLDATETIME,
	@RC		INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @MASTERID UNIQUEIDENTIFIER

	SELECT @MASTERID = TT_ID_MASTER
	FROM Distr.TechTypeDetail
	WHERE TT_ID = @IDLIST

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'TECH_TYPE', @MASTERID, @OLD OUTPUT


	UPDATE	Distr.TechTypeDetail
	SET		TT_END	=	@DATE,
			TT_REF	=	3
	WHERE	TT_ID	=	@IDLIST

	EXEC Common.PROTOCOL_VALUE_GET 'TECH_TYPE', NULL, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'TECH_TYPE', '��������', @MASTERID, @OLD, @NEW

END

GO
