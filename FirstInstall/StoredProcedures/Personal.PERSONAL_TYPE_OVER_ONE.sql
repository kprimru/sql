USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Personal].[PERSONAL_TYPE_OVER_ONE]
	@IDLIST	UNIQUEIDENTIFIER,
	@DATE	SMALLDATETIME,
	@RC		INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON


	DECLARE @MASTERID UNIQUEIDENTIFIER

	SELECT @MASTERID = PT_ID_MASTER
	FROM Personal.PersonalTypeDetail
	WHERE PT_ID = @IDLIST

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'PERSONAL_TYPE', @MASTERID, @OLD OUTPUT

	UPDATE	Personal.PersonalTypeDetail
	SET		PT_END	=	@DATE,
			PT_REF	=	3
	WHERE	PT_ID	=	@IDLIST


	EXEC Common.PROTOCOL_VALUE_GET 'PERSONAL_TYPE', NULL, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'PERSONAL_TYPE', '��������', @MASTERID, @OLD, @NEW

END

