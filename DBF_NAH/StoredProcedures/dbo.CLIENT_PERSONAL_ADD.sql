USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_PERSONAL_ADD]
	@clientid INT,
	@surname VARCHAR(100),
	@name VARCHAR(100),
	@otch VARCHAR(100),
	@positionid SMALLINT,
	@reportpositionid SMALLINT,
	--  @phone varchar(100),
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.ClientPersonalTable(PER_ID_CLIENT, PER_FAM, PER_NAME, PER_OTCH, PER_ID_POS, PER_ID_REPORT_POS)
	VALUES (@clientid, @surname, @name, @otch, @positionid, @reportpositionid)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN


	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_ADD] TO rl_client_personal_w;
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_ADD] TO rl_client_w;
GO