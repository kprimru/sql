USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:			%authorname%
���� ��������:	03.02.2009
��������:		�������� (�����������)
				����������� � �������
				(��������) �� ��� ���������
				������������� ��� ������ ��
*/

CREATE PROCEDURE [dbo].[DISTRS_CONTRACT_ADD]
	@co_id INT,
	@distrs VARCHAR(1000)
AS
BEGIN
	SET NOCOUNT ON


	IF OBJECT_ID('tempdb..#distrstmp') IS NOT NULL
		DROP TABLE #distrstmp

	  CREATE TABLE #distrstmp
		(
		  distr	INT
		)

	IF @distrs IS NOT NULL
		BEGIN
		  --������� ������� � �������� ������ ��������
		  INSERT INTO #distrstmp
			SELECT DISTINCT * FROM dbo.GET_TABLE_FROM_LIST(@distrs, ',')
		  END

	INSERT INTO dbo.ContractDistrTable SELECT @co_id , distr FROM #distrstmp


	/*IF @returnvalue = 1
	  SELECT SCOPE_IDENTITY() AS NEW_IDEN
	*/

	IF OBJECT_ID('tempdb..#distrstmp') IS NOT NULL
		DROP TABLE #distrstmp

	SET NOCOUNT OFF
END