USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 05.11.2008
��������:	  ���������� 0, � ������ ���� 
               �������� ���������� ����� ������� 
               (��� �� ������� �� � ��������������), 
               -1 � ��������� ������
*/

CREATE PROCEDURE [dbo].[MARKET_AREA_TRY_DELETE] 
	@marketareaid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	SELECT @res AS RES, @txt AS TXT

	-- ��������� 30.04.2009, �.������
	IF EXISTS(SELECT * FROM dbo.SubhostCityTable WHERE SC_ID_MARKET_AREA = @marketareaid)
		BEGIN
			SET @res = 1
			SET @txt = @txt	+	'���������� ������� �������� ����������, ��� ��� ��� ������� ' +
								'� ����� ��� ����������� ����������. '
		END
	--

	SET NOCOUNT OFF
END