USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Mailing].[WEB_DISTR_CHECK]
	@STR	NVARCHAR(64),
	@MSG	NVARCHAR(256) OUTPUT,
	@STATUS	SMALLINT OUTPUT,
	@HOST	INT = NULL OUTPUT,
	@DISTR	INT = NULL OUTPUT,
	@COMP	TINYINT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DISTR_S	NVARCHAR(64)
	DECLARE @COMP_S		NVARCHAR(64)
	
	SET @STR = LTRIM(RTRIM(@STR))

	IF CHARINDEX('/', @STR) <> 0
	BEGIN
		SET @DISTR_S = LEFT(@STR, CHARINDEX('/', @STR) - 1)
		SET @COMP_S = RIGHT(@STR, LEN(@STR) - CHARINDEX('/', @STR))
	END
	ELSE
	BEGIN
		SET @DISTR_S = @STR
		SET @COMP_S = '1'
	END
	
	DECLARE @ERROR	BIT

	
	SET @ERROR = 0
	
	BEGIN TRY
		SET @DISTR = CONVERT(INT, @DISTR_S)
		SET @COMP = CONVERT(INT, @COMP_S)
	END TRY
	BEGIN CATCH
		SET @ERROR = 1
	END CATCH
	
	IF @ERROR = 1
	BEGIN
		SET @STATUS = 1
		SET @MSG = '������� ������ ����� ������������. �� ������ ���� ������ ���� � ���� �����, ���� � ���� ���� �����, ����������� �������� "/"'
		
		RETURN
	END

	IF NOT EXISTS
		(
			SELECT *
			FROM dbo.RegNodeMainSystemView
			WHERE MainDistrNumber = @DISTR AND MainCompNumber = @COMP
		)
	BEGIN
		SET @STATUS = 1
		SET @MSG = '�� �� ���������������� � ��� ��� ������'
		
		RETURN
	END
	
	SELECT @HOST = MainHostID
	FROM dbo.RegNodeMainSystemView
	WHERE MainDistrNumber = @DISTR AND MainCompNumber = @COMP
	
	IF (SELECT DS_REG FROM Reg.RegNodeSearchView WITH(NOEXPAND) WHERE HostID = @HOST AND DistrNumber = @DISTR AND CompNumber = @COMP) <> 0
	BEGIN
		SET @STATUS = 1
		SET @MSG = '����������� �������� �� �������������. ��� ����, ����� ������������ � �������������, ���������� � ���.'
		
		RETURN
	END

	
	SET @STATUS = 0
END
