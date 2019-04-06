USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 20.11.2008
��������:	  ���������� 0, ���� ��� ������������ 
               ����� ������� �� �����������, 
               -1 � ��������� ������
*/

CREATE PROCEDURE [dbo].[PRICE_GOOD_TRY_DELETE] 
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	-- ��������� 29.04.2009, �.������
	IF EXISTS(SELECT * FROM dbo.PriceSystemTable WHERE PS_ID_PGD = @id)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� ������ �������������, ��� ��� ������� ������������ ���� ������.'
		END


	SELECT @res AS RES, @txt AS TXT
	  
	SET NOCOUNT OFF
END
