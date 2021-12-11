USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reg].[OnlinePassword]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_SYSTEM]   Int                   NOT NULL,
        [ID_HOST]     Int                   NOT NULL,
        [DISTR]       Int                   NOT NULL,
        [COMP]        TinyInt               NOT NULL,
        [PASS]        NVarChar(Max)         NOT NULL,
        [STATUS]      TinyInt               NOT NULL,
        [UPD_DATE]    DateTime              NOT NULL,
        [UPD_USER]    NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Reg.OnlinePassword] PRIMARY KEY CLUSTERED ([ID])
);
GO
