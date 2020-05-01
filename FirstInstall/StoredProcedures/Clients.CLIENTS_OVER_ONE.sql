USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Clients].[CLIENTS_OVER_ONE]
	@IDLIST	UNIQUEIDENTIFIER,
	@DATE	SMALLDATETIME,
	@RC		INT	=	NULL	OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @MASTERID UNIQUEIDENTIFIER

	SELECT @MASTERID = CL_ID_MASTER
	FROM Clients.ClientDetail
	WHERE CL_ID = @IDLIST

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'CLIENTS', @MASTERID, @OLD OUTPUT

	UPDATE	Clients.ClientDetail
	SET		CL_END	=	@DATE,
			CL_REF	=	3
	WHERE	CL_ID	=	@IDLIST

	UPDATE Clients.Clients
	SET CLMS_LAST = GETDATE()
	WHERE CLMS_ID = @MASTERID

	EXEC Common.PROTOCOL_VALUE_GET 'CLIENTS', NULL, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'CLIENTS', '��������', @MASTERID, @OLD, @NEW

END

