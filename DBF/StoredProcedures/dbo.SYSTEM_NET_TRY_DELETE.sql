USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 23.09.2008
��������:	  ���������� 0, ���� ��� ���� 
               � ��������� ����� ����� ������� 
               (�� ���� �� ��������� �� ���� 
               ������ � ���� ������), 
               -1 � ��������� ������
*/

CREATE PROCEDURE [dbo].[SYSTEM_NET_TRY_DELETE] 
	@systemnetid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	-- ��������� 29.04.2009, �.������
	IF EXISTS(SELECT * FROM dbo.DistrFinancingTable WHERE DF_ID_NET = @systemnetid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� ��� ����, ��� ��� ������� ���������� ��������� � ���� �����. '
		END

	IF EXISTS(SELECT * FROM dbo.SystemNetCountTable WHERE SNC_ID_SN = @systemnetid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + CHAR(13) + '���������� ������� ��� ����, ��� ��� � ��� ������� ���������� ������� �������. '
		END
	--

	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF
END

