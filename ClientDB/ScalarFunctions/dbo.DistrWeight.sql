USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[DistrWeight]
(
	@SYS	INT,
	@NET	INT,
	@TYPE	NVARCHAR(128),
	@DATE	SMALLDATETIME
)
RETURNS DECIMAL(8, 4)
AS
BEGIN
	DECLARE @RES DECIMAL(8, 4)

	DECLARE @PERIOD	UNIQUEIDENTIFIER
	DECLARE @SYS_REG NVARCHAR(64)

	SELECT @PERIOD = ID
	FROM Common.Period
	WHERE @DATE BETWEEN START_REPORT AND FINISH_REPORT AND TYPE = 2

	SELECT @SYS_REG = SystemBaseName
	FROM dbo.SystemTable
	WHERE SystemID = @SYS

	SELECT @RES =
			CASE
				WHEN @TYPE IN ('�/�', '�/� ������.�����', '���', '��� ��������.�����', '����� �', '���', '��� ���') THEN NULL
				WHEN @TYPE IN ('��3') AND @SYS_REG LIKE 'SPK-%' THEN WEIGHT2
				WHEN @TYPE = '��2' THEN a.WEIGHT2
				ELSE a.WEIGHT
			END * b.WEIGHT
	FROM
		dbo.SystemWeight a
		CROSS JOIN dbo.DistrTypeCoef b
	WHERE ID_SYSTEM = @SYS AND ID_PERIOD = @PERIOD AND ID_MONTH = @PERIOD AND ID_NET = @NET

	RETURN @RES
END
GO
