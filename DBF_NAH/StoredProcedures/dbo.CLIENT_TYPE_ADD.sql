USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
��������:
*/

ALTER PROCEDURE [dbo].[CLIENT_TYPE_ADD]
	@name VARCHAR(50),
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.ClientTypeTable (CLT_NAME, CLT_ACTIVE)
	VALUES (@name, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_TYPE_ADD] TO rl_client_type_w;
GO