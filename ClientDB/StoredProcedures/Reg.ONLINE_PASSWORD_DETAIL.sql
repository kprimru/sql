USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reg].[ONLINE_PASSWORD_DETAIL]
	@HOST	INT,
	@DISTR	INT,
	@COMP	TINYINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		SystemShortName AS [�������], PASS AS [������], 
		CASE STATUS WHEN 1 THEN '�����������' WHEN 2 THEN '������' WHEN 3 THEN '������' ELSE '???' END AS [������], 
		UPD_DATE AS [���� ��������� ������], UPD_USER AS [������������]
	FROM 
		Reg.OnlinePassword a
		INNER JOIN dbo.SystemTable b ON a.ID_SYSTEM = b.SystemID
	WHERE ID_HOST = @HOST AND DISTR = @DISTR AND COMP = @COMP 
	ORDER BY UPD_DATE DESC
END
