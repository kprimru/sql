USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[DISTR_TYPE_OVER_ONE]
	@IDLIST	UNIQUEIDENTIFIER,
	@DATE	SMALLDATETIME,
	@RC		INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @MASTERID UNIQUEIDENTIFIER

	SELECT @MASTERID = DT_ID_MASTER
	FROM Distr.DistrTypeDetail
	WHERE DT_ID = @IDLIST

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'DISTR_TYPE', @MASTERID, @OLD OUTPUT

	UPDATE	Distr.DistrTypeDetail
	SET		DT_END	=	@DATE,
			DT_REF	=	3
	WHERE	DT_ID	=	@IDLIST

	EXEC Common.PROTOCOL_VALUE_GET 'DISTR_TYPE', NULL, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'DISTR_TYPE', '��������', @MASTERID, @OLD, @NEW
END

GO
