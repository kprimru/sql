USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ���������� 0, ���� ������ �����
               ������� �� ����������� (�� ����
               �� ��������� �� ���� ������
               �� ����������� ������),
                -1 � ��������� ������
*/

ALTER PROCEDURE [dbo].[REGION_TRY_DELETE]
	@regionid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.CityTable WHERE CT_ID_RG = @regionid)
	BEGIN
		SET @res = 1
		SET @txt = @txt + '������ ������ ������ � ������ ��� ���������� ���������� �������. ' +
						  '�������� ����������, ���� ��������� ������ ����� ������ ���� ' +
						  '�� � ������ ����������� ������.'
	END

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[REGION_TRY_DELETE] TO rl_region_d;
GO