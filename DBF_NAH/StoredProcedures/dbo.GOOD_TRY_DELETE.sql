USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:			������� �������/������ ��������
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[GOOD_TRY_DELETE]
	@gdid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	SELECT @res AS RES, @txt AS TXT
END
GO
GRANT EXECUTE ON [dbo].[GOOD_TRY_DELETE] TO rl_good_d;
GO