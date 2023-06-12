USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemsBanksTry]
(
        [System_Id]      SmallInt           NOT NULL,
        [DistrType_Id]   SmallInt           NOT NULL,
        [InfoBank_Id]    SmallInt           NOT NULL,
        [Required]       Bit                NOT NULL,
        [Start]          SmallDateTime          NULL,
        CONSTRAINT [PK_dbo.SystemsBanksTry] PRIMARY KEY CLUSTERED ([System_Id],[DistrType_Id],[InfoBank_Id])
);
GO
