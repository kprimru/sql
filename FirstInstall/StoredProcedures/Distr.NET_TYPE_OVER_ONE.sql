USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[NET_TYPE_OVER_ONE]
	@IDLIST	UNIQUEIDENTIFIER,
	@DATE	SMALLDATETIME,
	@RC		INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @MASTERID UNIQUEIDENTIFIER

	SELECT @MASTERID = NT_ID_MASTER
	FROM Distr.NetTypeDetail
	WHERE NT_ID = @IDLIST

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'NET_TYPE', @MASTERID, @OLD OUTPUT


	UPDATE	Distr.NetTypeDetail
	SET		NT_END	=	@DATE,
			NT_REF	=	3
	WHERE	NT_ID	=	@IDLIST

	EXEC Common.PROTOCOL_VALUE_GET 'NET_TYPE', NULL, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'NET_TYPE', '��������', @MASTERID, @OLD, @NEW
END

GO
