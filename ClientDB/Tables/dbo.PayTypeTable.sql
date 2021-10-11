USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayTypeTable]
(
        [PayTypeID]      Int           Identity(1,1)   NOT NULL,
        [PayTypeName]    VarChar(50)                   NOT NULL,
        [PayTypeMonth]   SmallInt                          NULL,
        CONSTRAINT [PK_dbo.PayTypeTable] PRIMARY KEY CLUSTERED ([PayTypeID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.PayTypeTable(PayTypeName)] ON [dbo].[PayTypeTable] ([PayTypeName] ASC);
GO
