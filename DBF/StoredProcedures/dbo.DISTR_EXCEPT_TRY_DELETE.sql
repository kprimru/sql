USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 18.11.2008
��������:	  ���������� 0, ���� ����������� � 
               ��������� ����� ����� ������� �� 
               ������, -1 � ��������� ������
*/

CREATE PROCEDURE [dbo].[DISTR_EXCEPT_TRY_DELETE] 
	@distrid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''	

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END
GRANT EXECUTE ON [dbo].[DISTR_EXCEPT_TRY_DELETE] TO rl_reg_node_report_r