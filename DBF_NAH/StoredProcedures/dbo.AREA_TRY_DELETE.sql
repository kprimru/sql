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

ALTER PROCEDURE [dbo].[AREA_TRY_DELETE]
	@areaid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.CityTable WHERE CT_ID_AREA = @areaid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '������ ����� ������ � ������ ��� ���������� �������. ' +
							  '�������� ����������, ���� ��������� ����� ����� ������ ���� ' +
							  '�� � ������ ������.'
		END

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END







GO
GRANT EXECUTE ON [dbo].[AREA_TRY_DELETE] TO rl_area_d;
GO