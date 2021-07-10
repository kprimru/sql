USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[GOOD_ADD]
	@name VARCHAR(150),
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.GoodTable(GD_NAME, GD_ACTIVE)
	VALUES (@name, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN
END


GO
GRANT EXECUTE ON [dbo].[GOOD_ADD] TO rl_good_w;
GO