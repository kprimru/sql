USE [DBF]
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

CREATE PROCEDURE [dbo].[SALE_OBJECT_TRY_DELETE]
	@soid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''	

	-- ��������� 29.04.2009, �.������
	IF EXISTS(SELECT * FROM dbo.SystemTable WHERE SYS_ID_SO = @soid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� ������ �������, ��� ��� ���������� ����������� � ���� �������. '
		END
	--

	SELECT @res AS RES, @txt AS TXT
END



