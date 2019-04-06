USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Personal].[PERSONAL_TYPE_UPDATE]
	@PT_ID		UNIQUEIDENTIFIER,
	@PT_NAME	VARCHAR(50),
	@PT_ALIAS	VARCHAR(50),
	@PT_DATE	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @PT_ID_MASTER UNIQUEIDENTIFIER
	
	SELECT @PT_ID_MASTER = PT_ID_MASTER
	FROM Personal.PersonalTypeDetail
	WHERE PT_ID = @PT_ID

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'PERSONAL_TYPE', @PT_ID_MASTER, @OLD OUTPUT

	UPDATE	Personal.PersonalTypeDetail
	SET		PT_NAME		=	@PT_NAME,
			PT_ALIAS	=	@PT_ALIAS,
			PT_DATE		=	@PT_DATE
	WHERE	PT_ID		=	@PT_ID 

	UPDATE	Personal.PersonalType
	SET		PTMS_LAST	=	GETDATE()
	WHERE	PTMS_ID	=
		(
			SELECT	PT_ID_MASTER
			FROM	Personal.PersonalTypeDetail	
			WHERE	PT_ID	=	@PT_ID
		)

	EXEC Common.PROTOCOL_VALUE_GET 'PERSONAL_TYPE', @PT_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'PERSONAL_TYPE', '��������������', @PT_ID_MASTER, @OLD, @NEW
END

